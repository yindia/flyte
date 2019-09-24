package impl

import (
	"bytes"
	"context"
	"strconv"
	"time"

	"github.com/lyft/flytestdlib/promutils"
	"github.com/prometheus/client_golang/prometheus"

	"github.com/golang/protobuf/ptypes"

	"github.com/lyft/flytestdlib/storage"

	"github.com/lyft/flytestdlib/logger"

	"github.com/lyft/flyteadmin/pkg/common"
	"github.com/lyft/flyteadmin/pkg/errors"
	"github.com/lyft/flyteadmin/pkg/manager/impl/util"
	"github.com/lyft/flyteadmin/pkg/manager/impl/validation"
	"github.com/lyft/flyteadmin/pkg/manager/interfaces"
	"github.com/lyft/flyteadmin/pkg/repositories"
	repoInterfaces "github.com/lyft/flyteadmin/pkg/repositories/interfaces"
	"github.com/lyft/flyteadmin/pkg/repositories/models"
	"github.com/lyft/flyteadmin/pkg/repositories/transformers"
	runtimeInterfaces "github.com/lyft/flyteadmin/pkg/runtime/interfaces"
	workflowengine "github.com/lyft/flyteadmin/pkg/workflowengine/impl"
	workflowengineInterfaces "github.com/lyft/flyteadmin/pkg/workflowengine/interfaces"
	"github.com/lyft/flyteidl/gen/pb-go/flyteidl/admin"
	"github.com/lyft/flyteidl/gen/pb-go/flyteidl/core"
	compiler "github.com/lyft/flytepropeller/pkg/compiler/common"
	"google.golang.org/grpc/codes"
)

var defaultStorageOptions = storage.Options{}

type workflowMetrics struct {
	Scope                   promutils.Scope
	CompilationFailures     prometheus.Counter
	TypedInterfaceSizeBytes prometheus.Summary
}

type WorkflowManager struct {
	db            repositories.RepositoryInterface
	config        runtimeInterfaces.Configuration
	compiler      workflowengineInterfaces.Compiler
	storageClient *storage.DataStore
	storagePrefix []string
	metrics       workflowMetrics
}

func (w *WorkflowManager) setDefaults(request admin.WorkflowCreateRequest) (admin.WorkflowCreateRequest, error) {
	// TODO: Also add environment and configuration defaults once those have been determined.
	if request.Id == nil {
		return request, errors.NewFlyteAdminError(codes.InvalidArgument, "missing identifier for WorkflowCreateRequest")
	}
	request.Spec.Template.Id = request.Id
	return request, nil
}

// TODO: Once the SDK sends subworkflows, pipe them through to calls to GetRequirements & CompileWorkflow.
func (w *WorkflowManager) getCompiledWorkflow(
	ctx context.Context, request admin.WorkflowCreateRequest) (admin.WorkflowClosure, error) {
	reqs, err := w.compiler.GetRequirements(request.Spec.Template, nil)
	if err != nil {
		w.metrics.CompilationFailures.Inc()
		logger.Errorf(ctx, "Failed to get workflow requirements for template [%+v] with err %v",
			request.Spec.Template, err)
		return admin.WorkflowClosure{}, err
	}

	var tasks = make([]*core.CompiledTask, len(reqs.GetRequiredTaskIds()))
	for idx, taskID := range reqs.GetRequiredTaskIds() {
		task, err := util.GetTask(ctx, w.db, taskID)
		if err != nil {
			logger.Debugf(ctx, "Failed to get task with id [%+v] when compiling workflow with id [%+v] with err %v",
				taskID, request.Id, err)
			return admin.WorkflowClosure{}, err
		}
		tasks[idx] = task.Closure.CompiledTask
	}

	var launchPlans = make([]compiler.InterfaceProvider, len(reqs.GetRequiredLaunchPlanIds()))
	for idx, launchPlanID := range reqs.GetRequiredLaunchPlanIds() {
		var launchPlanModel models.LaunchPlan
		launchPlanModel, err = util.GetLaunchPlanModel(ctx, w.db, launchPlanID)
		if err != nil {
			logger.Debugf(ctx, "Failed to get launch plan with id [%+v] when compiling workflow with id [%+v] with err %v",
				launchPlanID, request.Id, err)
			return admin.WorkflowClosure{}, err
		}
		var launchPlanInterfaceProvider workflowengine.InterfaceProvider
		launchPlanInterfaceProvider, err = workflowengine.NewLaunchPlanInterfaceProvider(launchPlanModel, launchPlanID)
		if err != nil {
			logger.Debugf(ctx, "Failed to create LaunchPlanInterfaceProvider for launch plan [%+v] with err %v",
				launchPlanModel, err)
			return admin.WorkflowClosure{}, err
		}
		launchPlans[idx] = launchPlanInterfaceProvider
	}

	closure, err := w.compiler.CompileWorkflow(request.Spec.Template, nil, tasks, launchPlans)
	if err != nil {
		w.metrics.CompilationFailures.Inc()
		logger.Debugf(ctx, "Failed to compile workflow with id [%+v] with err %v", request.Id, err)
		return admin.WorkflowClosure{}, err
	}
	createdAt, err := ptypes.TimestampProto(time.Now())
	if err != nil {
		return admin.WorkflowClosure{}, errors.NewFlyteAdminErrorf(codes.Internal,
			"Failed to serialize CreatedAt: %v when saving compiled workflow %+v", err, request.Id)
	}
	return admin.WorkflowClosure{
		CompiledWorkflow: closure,
		CreatedAt:        createdAt,
	}, nil
}

func (w *WorkflowManager) createDataReference(
	ctx context.Context, identifier *core.Identifier) (storage.DataReference, error) {
	nestedSubKeys := []string{
		identifier.Project,
		identifier.Domain,
		identifier.Name,
		identifier.Version,
	}
	nestedKeys := append(w.storagePrefix, nestedSubKeys...)
	return w.storageClient.ConstructReference(ctx, w.storageClient.GetBaseContainerFQN(ctx), nestedKeys...)
}

func (w *WorkflowManager) CreateWorkflow(
	ctx context.Context,
	request admin.WorkflowCreateRequest) (*admin.WorkflowCreateResponse, error) {
	if err := validation.ValidateWorkflow(ctx, request, w.db, w.config.ApplicationConfiguration()); err != nil {
		return nil, err
	}
	finalizedRequest, err := w.setDefaults(request)
	if err != nil {
		logger.Debugf(ctx, "Failed to set defaults for workflow with id [%+v] with err %v", request.Id, err)
		return nil, err
	}
	// Validate that the workflow compiles.
	workflowClosure, err := w.getCompiledWorkflow(ctx, finalizedRequest)
	if err != nil {
		logger.Errorf(ctx, "Failed to compile workflow with err: %v", err)
		return nil, errors.NewFlyteAdminErrorf(codes.Internal,
			"failed to compile workflow for [%+v] with err %v", request.Id, err)
	}
	err = validation.ValidateCompiledWorkflow(
		*request.Id, workflowClosure, w.config.RegistrationValidationConfiguration())
	if err != nil {
		return nil, err
	}
	workflowDigest, err := util.GetWorkflowDigest(ctx, workflowClosure.CompiledWorkflow)
	if err != nil {
		logger.Errorf(ctx, "failed to compute workflow digest with err %v", err)
		return nil, err
	}

	// Assert that a matching workflow doesn't already exist before uploading the workflow closure.
	existingMatchingWorkflow, err := util.GetWorkflowModel(ctx, w.db, *request.Id)
	// Check that no identical or conflicting workflows exist.
	if err == nil {
		// A workflow's structure is uniquely defined by its collection of nodes.
		if bytes.Equal(workflowDigest, existingMatchingWorkflow.Digest) {
			return nil, errors.NewFlyteAdminErrorf(
				codes.AlreadyExists, "identical workflow already exists with id %v", request.Id)
		}
		return nil, errors.NewFlyteAdminErrorf(codes.InvalidArgument,
			"workflow with different structure already exists with id %v", request.Id)
	} else if flyteAdminError, ok := err.(errors.FlyteAdminError); !ok || flyteAdminError.Code() != codes.NotFound {
		logger.Debugf(ctx, "Failed to get workflow for comparison in CreateWorkflow with ID [%+v] with err %v",
			request.Id, err)
		return nil, err
	}

	remoteClosureDataRef, err := w.createDataReference(ctx, request.Spec.Template.Id)
	if err != nil {
		logger.Infof(ctx, "failed to construct data reference for workflow closure with id [%+v] with err %v",
			request.Id, err)
		return nil, errors.NewFlyteAdminErrorf(codes.Internal,
			"failed to construct data reference for workflow closure with id [%+v] and err %v", request.Id, err)
	}
	err = w.storageClient.WriteProtobuf(ctx, remoteClosureDataRef, defaultStorageOptions, &workflowClosure)

	if err != nil {
		logger.Infof(ctx,
			"failed to write marshaled workflow with id [%+v] to storage %s with err %v and base container: %s",
			request.Id, remoteClosureDataRef.String(), err, w.storageClient.GetBaseContainerFQN(ctx))
		return nil, errors.NewFlyteAdminErrorf(codes.Internal,
			"failed to write marshaled workflow [%+v] to storage %s with err %v and base container: %s",
			request.Id, remoteClosureDataRef.String(), err, w.storageClient.GetBaseContainerFQN(ctx))
	}
	// Save the workflow & its reference to the offloaded, compiled workflow in the database.
	workflowModel, err := transformers.CreateWorkflowModel(
		finalizedRequest, remoteClosureDataRef.String(), workflowDigest)
	if err != nil {
		logger.Errorf(ctx,
			"Failed to transform workflow model for request [%+v] and remoteClosureIdentifier [%s] with err: %v",
			finalizedRequest, remoteClosureDataRef.String(), err)
		return nil, err
	}
	if err = w.db.WorkflowRepo().Create(ctx, workflowModel); err != nil {
		logger.Infof(ctx, "Failed to create workflow model [%+v] with err %v", request.Id, err)
		return nil, err
	}
	w.metrics.TypedInterfaceSizeBytes.Observe(float64(len(workflowModel.TypedInterface)))
	return &admin.WorkflowCreateResponse{}, nil
}

func (w *WorkflowManager) GetWorkflow(ctx context.Context, request admin.ObjectGetRequest) (*admin.Workflow, error) {
	if err := validation.ValidateIdentifier(request.Id, common.Workflow); err != nil {
		logger.Debugf(ctx, "invalid identifier [%+v]: %v", request.Id, err)
		return nil, err
	}
	workflow, err := util.GetWorkflow(ctx, w.db, w.storageClient, *request.Id)
	if err != nil {
		logger.Infof(ctx, "Failed to get workflow with id [%+v] with err %v", request.Id, err)
		return nil, err
	}
	return workflow, nil
}

// Returns workflows *without* a populated workflow closure.
func (w *WorkflowManager) ListWorkflows(
	ctx context.Context, request admin.ResourceListRequest) (*admin.WorkflowList, error) {
	// Check required fields
	if err := validation.ValidateResourceListRequest(request); err != nil {
		return nil, err
	}
	filters, err := util.GetDbFilters(util.FilterSpec{
		Project:        request.Id.Project,
		Domain:         request.Id.Domain,
		Name:           request.Id.Name,
		RequestFilters: request.Filters,
	}, common.Workflow)
	if err != nil {
		return nil, err
	}
	var sortParameter common.SortParameter
	if request.SortBy != nil {
		sortParameter, err = common.NewSortParameter(*request.SortBy)
		if err != nil {
			return nil, err
		}
	}
	offset, err := validation.ValidateToken(request.Token)
	if err != nil {
		return nil, errors.NewFlyteAdminErrorf(codes.InvalidArgument,
			"invalid pagination token %s for ListWorkflows", request.Token)
	}
	listWorkflowsInput := repoInterfaces.ListResourceInput{
		Limit:         int(request.Limit),
		Offset:        offset,
		InlineFilters: filters,
		SortParameter: sortParameter,
	}
	output, err := w.db.WorkflowRepo().List(ctx, listWorkflowsInput)
	if err != nil {
		logger.Debugf(ctx, "Failed to list workflows with [%+v] with err %v", request.Id, err)
		return nil, err
	}
	workflowList, err := transformers.FromWorkflowModels(output.Workflows)
	if err != nil {
		logger.Errorf(ctx,
			"Failed to transform workflow models [%+v] with err: %v", output.Workflows, err)
		return nil, err
	}
	var token string
	if len(output.Workflows) == int(request.Limit) {
		token = strconv.Itoa(offset + len(output.Workflows))
	}
	return &admin.WorkflowList{
		Workflows: workflowList,
		Token:     token,
	}, nil
}

func (w *WorkflowManager) ListWorkflowIdentifiers(ctx context.Context, request admin.NamedEntityIdentifierListRequest) (
	*admin.NamedEntityIdentifierList, error) {
	if err := validation.ValidateNamedEntityIdentifierListRequest(request); err != nil {
		logger.Debugf(ctx, "invalid request [%+v]: %v", request, err)
		return nil, err
	}

	filters, err := util.GetDbFilters(util.FilterSpec{
		Project: request.Project,
		Domain:  request.Domain,
	}, common.Workflow)
	if err != nil {
		return nil, err
	}
	var sortParameter common.SortParameter
	if request.SortBy != nil {
		sortParameter, err = common.NewSortParameter(*request.SortBy)
		if err != nil {
			return nil, err
		}
	}
	offset, err := validation.ValidateToken(request.Token)
	if err != nil {
		return nil, errors.NewFlyteAdminErrorf(codes.InvalidArgument,
			"invalid pagination token %s for ListWorkflowIdentifiers", request.Token)
	}
	listWorkflowsInput := repoInterfaces.ListResourceInput{
		Limit:         int(request.Limit),
		Offset:        offset,
		InlineFilters: filters,
		SortParameter: sortParameter,
	}

	output, err := w.db.WorkflowRepo().ListIdentifiers(ctx, listWorkflowsInput)
	if err != nil {
		logger.Debugf(ctx, "Failed to list workflow ids with project: %s and domain: %s with err %v",
			request.Project, request.Domain, err)
		return nil, err
	}

	var token string
	if len(output.Workflows) == int(request.Limit) {
		token = strconv.Itoa(offset + len(output.Workflows))
	}
	return &admin.NamedEntityIdentifierList{
		Entities: transformers.FromWorkflowModelsToIdentifiers(output.Workflows),
		Token:    token,
	}, nil

}

func NewWorkflowManager(
	db repositories.RepositoryInterface,
	config runtimeInterfaces.Configuration,
	compiler workflowengineInterfaces.Compiler,
	storageClient *storage.DataStore,
	storagePrefix []string,
	scope promutils.Scope) interfaces.WorkflowInterface {
	metrics := workflowMetrics{
		Scope: scope,
		CompilationFailures: scope.MustNewCounter(
			"compilation_failures", "any observed failures when compiling a workflow"),
		TypedInterfaceSizeBytes: scope.MustNewSummary("typed_interface_size_bytes",
			"size in bytes of serialized workflow TypedInterface"),
	}
	return &WorkflowManager{
		db:            db,
		config:        config,
		compiler:      compiler,
		storageClient: storageClient,
		storagePrefix: storagePrefix,
		metrics:       metrics,
	}
}
