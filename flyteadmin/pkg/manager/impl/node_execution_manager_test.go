package impl

import (
	"context"
	"errors"
	"testing"
	"time"

	"github.com/golang/protobuf/proto"
	"github.com/golang/protobuf/ptypes"
	"github.com/lyft/flyteadmin/pkg/common"
	dataMocks "github.com/lyft/flyteadmin/pkg/data/mocks"
	flyteAdminErrors "github.com/lyft/flyteadmin/pkg/errors"
	"github.com/lyft/flyteadmin/pkg/repositories"
	"github.com/lyft/flyteadmin/pkg/repositories/interfaces"
	repositoryMocks "github.com/lyft/flyteadmin/pkg/repositories/mocks"
	"github.com/lyft/flyteadmin/pkg/repositories/models"
	"github.com/lyft/flyteidl/gen/pb-go/flyteidl/admin"
	"github.com/lyft/flyteidl/gen/pb-go/flyteidl/core"
	"github.com/lyft/flyteidl/gen/pb-go/flyteidl/event"
	mockScope "github.com/lyft/flytestdlib/promutils"
	"github.com/stretchr/testify/assert"
	"google.golang.org/grpc/codes"
)

var occurredAt = time.Now().UTC()
var occurredAtProto, _ = ptypes.TimestampProto(occurredAt)
var request = admin.NodeExecutionEventRequest{
	RequestId: "request id",
	Event: &event.NodeExecutionEvent{
		ProducerId: "propeller",
		Id: &core.NodeExecutionIdentifier{
			NodeId: "node id",
			ExecutionId: &core.WorkflowExecutionIdentifier{
				Project: "project",
				Domain:  "domain",
				Name:    "name",
			},
		},
		OccurredAt: occurredAtProto,
		Phase:      core.NodeExecution_RUNNING,
		InputUri:   "input uri",
	},
}
var nodeExecutionIdentifier = core.NodeExecutionIdentifier{
	NodeId: "node id",
	ExecutionId: &core.WorkflowExecutionIdentifier{
		Project: "project",
		Domain:  "domain",
		Name:    "name",
	},
}
var workflowExecutionIdentifier = core.WorkflowExecutionIdentifier{
	Project: "project",
	Domain:  "domain",
	Name:    "name",
}

var mockNodeExecutionRemoteURL = dataMocks.NewMockRemoteURL()

func addGetExecutionCallback(t *testing.T, repository repositories.RepositoryInterface) {
	repository.ExecutionRepo().(*repositoryMocks.MockExecutionRepo).SetGetCallback(
		func(ctx context.Context, input interfaces.GetResourceInput) (models.Execution, error) {
			assert.Equal(t, "project", input.Project)
			assert.Equal(t, "domain", input.Domain)
			assert.Equal(t, "name", input.Name)
			return models.Execution{
				BaseModel: models.BaseModel{
					ID: uint(8),
				},
				ExecutionKey: models.ExecutionKey{
					Project: "project",
					Domain:  "domain",
					Name:    "name",
				},
			}, nil
		})
}

func TestCreateNodeEvent(t *testing.T) {
	repository := repositoryMocks.NewMockRepository()
	addGetExecutionCallback(t, repository)
	repository.NodeExecutionRepo().(*repositoryMocks.MockNodeExecutionRepo).SetGetCallback(
		func(ctx context.Context, input interfaces.GetNodeExecutionInput) (models.NodeExecution, error) {
			assert.True(t, proto.Equal(&core.NodeExecutionIdentifier{
				NodeId:      "node id",
				ExecutionId: &workflowExecutionIdentifier,
			}, &input.NodeExecutionIdentifier))
			return models.NodeExecution{}, flyteAdminErrors.NewFlyteAdminError(codes.NotFound, "foo")
		})
	expectedClosure := admin.NodeExecutionClosure{
		Phase:     request.Event.Phase,
		StartedAt: occurredAtProto,
		CreatedAt: occurredAtProto,
		UpdatedAt: occurredAtProto,
	}
	closureBytes, _ := proto.Marshal(&expectedClosure)
	repository.NodeExecutionRepo().(*repositoryMocks.MockNodeExecutionRepo).SetCreateCallback(
		func(ctx context.Context, event *models.NodeExecutionEvent, input *models.NodeExecution) error {
			assert.Equal(t, models.NodeExecutionEvent{
				NodeExecutionKey: models.NodeExecutionKey{
					NodeID: "node id",
					ExecutionKey: models.ExecutionKey{
						Project: "project",
						Domain:  "domain",
						Name:    "name",
					},
				},
				RequestID:  "request id",
				Phase:      core.NodeExecution_RUNNING.String(),
				OccurredAt: occurredAt,
			}, *event)
			assert.Equal(t, models.NodeExecution{
				NodeExecutionKey: models.NodeExecutionKey{
					NodeID: "node id",
					ExecutionKey: models.ExecutionKey{
						Project: "project",
						Domain:  "domain",
						Name:    "name",
					},
				},
				Phase:                  core.NodeExecution_RUNNING.String(),
				InputURI:               "input uri",
				StartedAt:              &occurredAt,
				Closure:                closureBytes,
				NodeExecutionCreatedAt: &occurredAt,
				NodeExecutionUpdatedAt: &occurredAt,
			}, *input)
			return nil
		})
	nodeExecManager := NewNodeExecutionManager(repository, mockScope.NewTestScope(), mockNodeExecutionRemoteURL)
	resp, err := nodeExecManager.CreateNodeEvent(context.Background(), request)
	assert.Nil(t, err)
	assert.NotNil(t, resp)
}

func TestCreateNodeEvent_Update(t *testing.T) {
	repository := repositoryMocks.NewMockRepository()
	addGetExecutionCallback(t, repository)
	repository.NodeExecutionRepo().(*repositoryMocks.MockNodeExecutionRepo).SetGetCallback(
		func(ctx context.Context, input interfaces.GetNodeExecutionInput) (models.NodeExecution, error) {
			assert.True(t, proto.Equal(&core.NodeExecutionIdentifier{
				NodeId:      "node id",
				ExecutionId: &workflowExecutionIdentifier,
			}, &input.NodeExecutionIdentifier))
			return models.NodeExecution{
				NodeExecutionKey: models.NodeExecutionKey{
					NodeID: "node id",
					ExecutionKey: models.ExecutionKey{
						Project: "project",
						Domain:  "domain",
						Name:    "name",
					},
				},
				Phase:     core.NodeExecution_UNDEFINED.String(),
				InputURI:  "input uri",
				StartedAt: &occurredAt,
			}, nil
		})
	repository.NodeExecutionRepo().(*repositoryMocks.MockNodeExecutionRepo).SetUpdateCallback(
		func(ctx context.Context, event *models.NodeExecutionEvent, nodeExecution *models.NodeExecution) error {
			expectedClosure := admin.NodeExecutionClosure{
				StartedAt: occurredAtProto,
				Phase:     core.NodeExecution_RUNNING,
				UpdatedAt: occurredAtProto,
			}
			expectedClosureBytes, _ := proto.Marshal(&expectedClosure)
			assert.Equal(t, models.NodeExecution{
				NodeExecutionKey: models.NodeExecutionKey{
					NodeID: "node id",
					ExecutionKey: models.ExecutionKey{
						Project: "project",
						Domain:  "domain",
						Name:    "name",
					},
				},
				Phase:                  core.NodeExecution_RUNNING.String(),
				InputURI:               "input uri",
				StartedAt:              &occurredAt,
				Closure:                expectedClosureBytes,
				NodeExecutionUpdatedAt: &occurredAt,
			}, *nodeExecution)

			return nil
		})
	nodeExecManager := NewNodeExecutionManager(repository, mockScope.NewTestScope(), mockNodeExecutionRemoteURL)
	resp, err := nodeExecManager.CreateNodeEvent(context.Background(), request)
	assert.Nil(t, err)
	assert.NotNil(t, resp)
}

func TestCreateNodeEvent_MissingExecution(t *testing.T) {
	repository := repositoryMocks.NewMockRepository()
	expectedErr := errors.New("expected error")
	repository.ExecutionRepo().(*repositoryMocks.MockExecutionRepo).SetGetCallback(
		func(ctx context.Context, input interfaces.GetResourceInput) (models.Execution, error) {
			return models.Execution{}, expectedErr
		})
	nodeExecManager := NewNodeExecutionManager(repository, mockScope.NewTestScope(), mockNodeExecutionRemoteURL)
	resp, err := nodeExecManager.CreateNodeEvent(context.Background(), request)
	assert.EqualError(t, err, "failed to get existing execution id: [project:\"project\""+
		" domain:\"domain\" name:\"name\" ] with err: expected error")
	assert.Nil(t, resp)
}

func TestCreateNodeEvent_CreateDatabaseError(t *testing.T) {
	repository := repositoryMocks.NewMockRepository()
	addGetExecutionCallback(t, repository)
	repository.NodeExecutionRepo().(*repositoryMocks.MockNodeExecutionRepo).SetGetCallback(
		func(ctx context.Context, input interfaces.GetNodeExecutionInput) (models.NodeExecution, error) {
			return models.NodeExecution{}, flyteAdminErrors.NewFlyteAdminError(codes.NotFound, "foo")
		})

	expectedErr := errors.New("expected error")
	repository.NodeExecutionRepo().(*repositoryMocks.MockNodeExecutionRepo).SetCreateCallback(
		func(ctx context.Context, event *models.NodeExecutionEvent, input *models.NodeExecution) error {
			return expectedErr
		})
	nodeExecManager := NewNodeExecutionManager(repository, mockScope.NewTestScope(), mockNodeExecutionRemoteURL)
	resp, err := nodeExecManager.CreateNodeEvent(context.Background(), request)
	assert.EqualError(t, err, expectedErr.Error())
	assert.Nil(t, resp)
}

func TestCreateNodeEvent_UpdateDatabaseError(t *testing.T) {
	repository := repositoryMocks.NewMockRepository()
	addGetExecutionCallback(t, repository)
	repository.NodeExecutionRepo().(*repositoryMocks.MockNodeExecutionRepo).SetGetCallback(
		func(ctx context.Context, input interfaces.GetNodeExecutionInput) (models.NodeExecution, error) {
			assert.True(t, proto.Equal(&core.NodeExecutionIdentifier{
				NodeId:      "node id",
				ExecutionId: &workflowExecutionIdentifier,
			}, &input.NodeExecutionIdentifier))
			return models.NodeExecution{
				NodeExecutionKey: models.NodeExecutionKey{
					NodeID: "node id",
					ExecutionKey: models.ExecutionKey{
						Project: "project",
						Domain:  "domain",
						Name:    "name",
					},
				},
				Phase:     core.NodeExecution_UNDEFINED.String(),
				InputURI:  "input uri",
				StartedAt: &occurredAt,
			}, nil
		})

	expectedErr := errors.New("expected error")
	repository.NodeExecutionRepo().(*repositoryMocks.MockNodeExecutionRepo).SetUpdateCallback(
		func(ctx context.Context, event *models.NodeExecutionEvent, nodeExecution *models.NodeExecution) error {
			return expectedErr
		})
	nodeExecManager := NewNodeExecutionManager(repository, mockScope.NewTestScope(), mockNodeExecutionRemoteURL)
	resp, err := nodeExecManager.CreateNodeEvent(context.Background(), request)
	assert.EqualError(t, err, expectedErr.Error())
	assert.Nil(t, resp)
}

func TestCreateNodeEvent_UpdateTerminalEventError(t *testing.T) {
	repository := repositoryMocks.NewMockRepository()
	addGetExecutionCallback(t, repository)
	repository.NodeExecutionRepo().(*repositoryMocks.MockNodeExecutionRepo).SetGetCallback(
		func(ctx context.Context, input interfaces.GetNodeExecutionInput) (models.NodeExecution, error) {
			assert.True(t, proto.Equal(&core.NodeExecutionIdentifier{
				NodeId:      "node id",
				ExecutionId: &workflowExecutionIdentifier,
			}, &input.NodeExecutionIdentifier))
			return models.NodeExecution{
				NodeExecutionKey: models.NodeExecutionKey{
					NodeID: "node id",
					ExecutionKey: models.ExecutionKey{
						Project: "project",
						Domain:  "domain",
						Name:    "name",
					},
				},
				Phase:     core.NodeExecution_SUCCEEDED.String(),
				InputURI:  "input uri",
				StartedAt: &occurredAt,
			}, nil
		})
	nodeExecManager := NewNodeExecutionManager(repository, mockScope.NewTestScope(), mockNodeExecutionRemoteURL)
	resp, err := nodeExecManager.CreateNodeEvent(context.Background(), request)
	assert.Nil(t, resp)
	assert.NotNil(t, err)
	adminError := err.(flyteAdminErrors.FlyteAdminError)
	assert.Equal(t, codes.FailedPrecondition, adminError.GRPCStatus().Code())
	details, ok := adminError.GRPCStatus().Details()[0].(*admin.EventFailureReason)
	assert.True(t, ok)
	_, ok = details.GetReason().(*admin.EventFailureReason_AlreadyInTerminalState)
	assert.True(t, ok)
}

func TestCreateNodeEvent_UpdateDuplicateEventError(t *testing.T) {
	repository := repositoryMocks.NewMockRepository()
	addGetExecutionCallback(t, repository)
	repository.NodeExecutionRepo().(*repositoryMocks.MockNodeExecutionRepo).SetGetCallback(
		func(ctx context.Context, input interfaces.GetNodeExecutionInput) (models.NodeExecution, error) {
			assert.True(t, proto.Equal(&core.NodeExecutionIdentifier{
				NodeId:      "node id",
				ExecutionId: &workflowExecutionIdentifier,
			}, &input.NodeExecutionIdentifier))
			return models.NodeExecution{
				NodeExecutionKey: models.NodeExecutionKey{
					NodeID: "node id",
					ExecutionKey: models.ExecutionKey{
						Project: "project",
						Domain:  "domain",
						Name:    "name",
					},
				},
				Phase:     core.NodeExecution_RUNNING.String(),
				InputURI:  "input uri",
				StartedAt: &occurredAt,
			}, nil
		})
	nodeExecManager := NewNodeExecutionManager(repository, mockScope.NewTestScope(), mockNodeExecutionRemoteURL)
	resp, err := nodeExecManager.CreateNodeEvent(context.Background(), request)
	assert.Equal(t, codes.AlreadyExists, err.(flyteAdminErrors.FlyteAdminError).Code())
	assert.Nil(t, resp)
}

func TestCreateNodeEvent_FirstEventIsTerminal(t *testing.T) {
	repository := repositoryMocks.NewMockRepository()
	addGetExecutionCallback(t, repository)
	repository.NodeExecutionRepo().(*repositoryMocks.MockNodeExecutionRepo).SetGetCallback(
		func(ctx context.Context, input interfaces.GetNodeExecutionInput) (models.NodeExecution, error) {
			return models.NodeExecution{}, flyteAdminErrors.NewFlyteAdminError(codes.NotFound, "foo")
		})
	nodeExecManager := NewNodeExecutionManager(repository, mockScope.NewTestScope(), mockNodeExecutionRemoteURL)
	succeededRequest := admin.NodeExecutionEventRequest{
		RequestId: "request id",
		Event: &event.NodeExecutionEvent{
			ProducerId: "propeller",
			Id: &core.NodeExecutionIdentifier{
				NodeId: "node id",
				ExecutionId: &core.WorkflowExecutionIdentifier{
					Project: "project",
					Domain:  "domain",
					Name:    "name",
				},
			},
			OccurredAt: occurredAtProto,
			Phase:      core.NodeExecution_SUCCEEDED,
			InputUri:   "input uri",
		},
	}
	resp, err := nodeExecManager.CreateNodeEvent(context.Background(), succeededRequest)
	assert.NotNil(t, resp)
	assert.Nil(t, err)
}

func TestGetNodeExecution(t *testing.T) {
	repository := repositoryMocks.NewMockRepository()
	expectedClosure := admin.NodeExecutionClosure{
		Phase: core.NodeExecution_SUCCEEDED,
	}
	closureBytes, _ := proto.Marshal(&expectedClosure)
	repository.NodeExecutionRepo().(*repositoryMocks.MockNodeExecutionRepo).SetGetCallback(
		func(ctx context.Context, input interfaces.GetNodeExecutionInput) (models.NodeExecution, error) {
			workflowExecutionIdentifier := core.WorkflowExecutionIdentifier{
				Project: "project",
				Domain:  "domain",
				Name:    "name",
			}
			assert.True(t, proto.Equal(&core.NodeExecutionIdentifier{
				NodeId:      "node id",
				ExecutionId: &workflowExecutionIdentifier,
			}, &input.NodeExecutionIdentifier))
			return models.NodeExecution{
				NodeExecutionKey: models.NodeExecutionKey{
					NodeID: "node id",
					ExecutionKey: models.ExecutionKey{
						Project: "project",
						Domain:  "domain",
						Name:    "name",
					},
				},
				Phase:     core.NodeExecution_SUCCEEDED.String(),
				InputURI:  "input uri",
				StartedAt: &occurredAt,
				Closure:   closureBytes,
			}, nil
		})
	nodeExecManager := NewNodeExecutionManager(repository, mockScope.NewTestScope(), mockNodeExecutionRemoteURL)
	nodeExecution, err := nodeExecManager.GetNodeExecution(context.Background(), admin.NodeExecutionGetRequest{
		Id: &nodeExecutionIdentifier,
	})
	assert.Nil(t, err)
	assert.True(t, proto.Equal(&admin.NodeExecution{
		Id:       &nodeExecutionIdentifier,
		InputUri: "input uri",
		Closure:  &expectedClosure,
	}, nodeExecution))
}

func TestGetNodeExecution_DatabaseError(t *testing.T) {
	repository := repositoryMocks.NewMockRepository()
	expectedErr := errors.New("expected error")
	repository.NodeExecutionRepo().(*repositoryMocks.MockNodeExecutionRepo).SetGetCallback(
		func(ctx context.Context, input interfaces.GetNodeExecutionInput) (models.NodeExecution, error) {
			return models.NodeExecution{}, expectedErr
		})
	nodeExecManager := NewNodeExecutionManager(repository, mockScope.NewTestScope(), mockNodeExecutionRemoteURL)
	nodeExecution, err := nodeExecManager.GetNodeExecution(context.Background(), admin.NodeExecutionGetRequest{
		Id: &nodeExecutionIdentifier,
	})
	assert.Nil(t, nodeExecution)
	assert.EqualError(t, err, expectedErr.Error())
}

func TestGetNodeExecution_TransformerError(t *testing.T) {
	repository := repositoryMocks.NewMockRepository()
	repository.NodeExecutionRepo().(*repositoryMocks.MockNodeExecutionRepo).SetGetCallback(
		func(ctx context.Context, input interfaces.GetNodeExecutionInput) (models.NodeExecution, error) {
			return models.NodeExecution{
				NodeExecutionKey: models.NodeExecutionKey{
					NodeID: "node id",
					ExecutionKey: models.ExecutionKey{
						Project: "project",
						Domain:  "domain",
						Name:    "name",
					},
				},
				Phase:     core.NodeExecution_SUCCEEDED.String(),
				InputURI:  "input uri",
				StartedAt: &occurredAt,
				Closure:   []byte("i'm invalid"),
			}, nil
		})
	nodeExecManager := NewNodeExecutionManager(repository, mockScope.NewTestScope(), mockNodeExecutionRemoteURL)
	nodeExecution, err := nodeExecManager.GetNodeExecution(context.Background(), admin.NodeExecutionGetRequest{
		Id: &nodeExecutionIdentifier,
	})
	assert.Nil(t, nodeExecution)
	assert.Equal(t, err.(flyteAdminErrors.FlyteAdminError).Code(), codes.Internal)
}

func TestListNodeExecutions(t *testing.T) {
	repository := repositoryMocks.NewMockRepository()
	expectedClosure := admin.NodeExecutionClosure{
		Phase: core.NodeExecution_SUCCEEDED,
	}
	closureBytes, _ := proto.Marshal(&expectedClosure)
	repository.NodeExecutionRepo().(*repositoryMocks.MockNodeExecutionRepo).SetListCallback(
		func(ctx context.Context, input interfaces.ListResourceInput) (
			interfaces.NodeExecutionCollectionOutput, error) {
			assert.Equal(t, 1, input.Limit)
			assert.Equal(t, 2, input.Offset)
			assert.Len(t, input.InlineFilters, 3)
			assert.Equal(t, common.Execution, input.InlineFilters[0].GetEntity())
			queryExpr, _ := input.InlineFilters[0].GetGormQueryExpr()
			assert.Equal(t, "project", queryExpr.Args)
			assert.Equal(t, "execution_project = ?", queryExpr.Query)

			assert.Equal(t, common.Execution, input.InlineFilters[1].GetEntity())
			queryExpr, _ = input.InlineFilters[1].GetGormQueryExpr()
			assert.Equal(t, "domain", queryExpr.Args)
			assert.Equal(t, "execution_domain = ?", queryExpr.Query)

			assert.Equal(t, common.Execution, input.InlineFilters[2].GetEntity())
			queryExpr, _ = input.InlineFilters[2].GetGormQueryExpr()
			assert.Equal(t, "name", queryExpr.Args)
			assert.Equal(t, "execution_name = ?", queryExpr.Query)

			assert.Len(t, input.MapFilters, 1)
			filter := input.MapFilters[0].GetFilter()
			assert.Equal(t, map[string]interface{}{
				"parent_task_execution_id": nil,
			}, filter)

			assert.Equal(t, "domain asc", input.SortParameter.GetGormOrderExpr())
			return interfaces.NodeExecutionCollectionOutput{
				NodeExecutions: []models.NodeExecution{
					{
						NodeExecutionKey: models.NodeExecutionKey{
							NodeID: "node id",
							ExecutionKey: models.ExecutionKey{
								Project: "project",
								Domain:  "domain",
								Name:    "name",
							},
						},
						Phase:     core.NodeExecution_SUCCEEDED.String(),
						InputURI:  "input uri",
						StartedAt: &occurredAt,
						Closure:   closureBytes,
					},
				},
			}, nil
		})
	nodeExecManager := NewNodeExecutionManager(repository, mockScope.NewTestScope(), mockNodeExecutionRemoteURL)
	nodeExecutions, err := nodeExecManager.ListNodeExecutions(context.Background(), admin.NodeExecutionListRequest{
		WorkflowExecutionId: &core.WorkflowExecutionIdentifier{
			Project: "project",
			Domain:  "domain",
			Name:    "name",
		},
		Limit: 1,
		Token: "2",
		SortBy: &admin.Sort{
			Direction: admin.Sort_ASCENDING,
			Key:       "domain",
		},
	})
	assert.Nil(t, err)
	assert.Len(t, nodeExecutions.NodeExecutions, 1)
	assert.True(t, proto.Equal(&admin.NodeExecution{
		Id: &core.NodeExecutionIdentifier{
			NodeId: "node id",
			ExecutionId: &core.WorkflowExecutionIdentifier{
				Project: "project",
				Domain:  "domain",
				Name:    "name",
			},
		},
		InputUri: "input uri",
		Closure:  &expectedClosure,
	}, nodeExecutions.NodeExecutions[0]))
	assert.Equal(t, "3", nodeExecutions.Token)
}

func TestListNodeExecutions_InvalidParams(t *testing.T) {
	nodeExecManager := NewNodeExecutionManager(nil, mockScope.NewTestScope(), mockNodeExecutionRemoteURL)
	_, err := nodeExecManager.ListNodeExecutions(context.Background(), admin.NodeExecutionListRequest{
		Filters: "eq(execution.project, project)",
	})
	assert.Equal(t, codes.InvalidArgument, err.(flyteAdminErrors.FlyteAdminError).Code())

	_, err = nodeExecManager.ListNodeExecutions(context.Background(), admin.NodeExecutionListRequest{
		Limit: 1,
	})
	assert.Equal(t, codes.InvalidArgument, err.(flyteAdminErrors.FlyteAdminError).Code())

	_, err = nodeExecManager.ListNodeExecutions(context.Background(), admin.NodeExecutionListRequest{
		Limit:   1,
		Filters: "foo",
	})
	assert.Equal(t, codes.InvalidArgument, err.(flyteAdminErrors.FlyteAdminError).Code())
}

func TestListNodeExecutions_DatabaseError(t *testing.T) {
	repository := repositoryMocks.NewMockRepository()
	expectedErr := errors.New("expected error")
	repository.NodeExecutionRepo().(*repositoryMocks.MockNodeExecutionRepo).SetListCallback(
		func(ctx context.Context, input interfaces.ListResourceInput) (
			interfaces.NodeExecutionCollectionOutput, error) {
			return interfaces.NodeExecutionCollectionOutput{}, expectedErr
		})
	nodeExecManager := NewNodeExecutionManager(repository, mockScope.NewTestScope(), mockNodeExecutionRemoteURL)
	nodeExecutions, err := nodeExecManager.ListNodeExecutions(context.Background(), admin.NodeExecutionListRequest{
		WorkflowExecutionId: &core.WorkflowExecutionIdentifier{
			Project: "project",
			Domain:  "domain",
			Name:    "name",
		},
		Limit: 1,
		Token: "2",
	})
	assert.Nil(t, nodeExecutions)
	assert.EqualError(t, err, expectedErr.Error())
}

func TestListNodeExecutions_TransformerError(t *testing.T) {
	repository := repositoryMocks.NewMockRepository()
	repository.NodeExecutionRepo().(*repositoryMocks.MockNodeExecutionRepo).SetListCallback(
		func(ctx context.Context, input interfaces.ListResourceInput) (
			interfaces.NodeExecutionCollectionOutput, error) {
			return interfaces.NodeExecutionCollectionOutput{
				NodeExecutions: []models.NodeExecution{
					{
						NodeExecutionKey: models.NodeExecutionKey{
							NodeID: "node id",
							ExecutionKey: models.ExecutionKey{
								Project: "project",
								Domain:  "domain",
								Name:    "name",
							},
						},
						Phase:     core.NodeExecution_SUCCEEDED.String(),
						InputURI:  "input uri",
						StartedAt: &occurredAt,
						Closure:   []byte("i'm invalid"),
					},
				},
			}, nil
		})
	nodeExecManager := NewNodeExecutionManager(repository, mockScope.NewTestScope(), mockNodeExecutionRemoteURL)
	nodeExecutions, err := nodeExecManager.ListNodeExecutions(context.Background(), admin.NodeExecutionListRequest{
		WorkflowExecutionId: &core.WorkflowExecutionIdentifier{
			Project: "project",
			Domain:  "domain",
			Name:    "name",
		},
		Limit: 1,
		Token: "2",
	})
	assert.Nil(t, nodeExecutions)
	assert.Equal(t, err.(flyteAdminErrors.FlyteAdminError).Code(), codes.Internal)
}

func TestListNodeExecutions_NothingToReturn(t *testing.T) {
	repository := repositoryMocks.NewMockRepository()
	repository.NodeExecutionRepo().(*repositoryMocks.MockNodeExecutionRepo).SetListCallback(
		func(ctx context.Context, input interfaces.ListResourceInput) (
			interfaces.NodeExecutionCollectionOutput, error) {
			return interfaces.NodeExecutionCollectionOutput{}, nil
		})
	var listExecutionsCalled bool
	repository.ExecutionRepo().(*repositoryMocks.MockExecutionRepo).SetListCallback(
		func(ctx context.Context, input interfaces.ListResourceInput) (
			interfaces.ExecutionCollectionOutput, error) {
			listExecutionsCalled = true
			return interfaces.ExecutionCollectionOutput{}, nil
		})
	nodeExecManager := NewNodeExecutionManager(repository, mockScope.NewTestScope(), mockNodeExecutionRemoteURL)
	_, err := nodeExecManager.ListNodeExecutions(context.Background(), admin.NodeExecutionListRequest{
		WorkflowExecutionId: &core.WorkflowExecutionIdentifier{
			Project: "project",
			Domain:  "domain",
			Name:    "name",
		},
		Limit: 1,
		Token: "2",
		SortBy: &admin.Sort{
			Direction: admin.Sort_ASCENDING,
			Key:       "domain",
		},
	})
	assert.Nil(t, err)
	assert.False(t, listExecutionsCalled)
}

func TestListNodeExecutionsForTask(t *testing.T) {
	repository := repositoryMocks.NewMockRepository()
	expectedClosure := admin.NodeExecutionClosure{
		Phase: core.NodeExecution_SUCCEEDED,
	}
	closureBytes, _ := proto.Marshal(&expectedClosure)
	repository.TaskExecutionRepo().(*repositoryMocks.MockTaskExecutionRepo).SetGetCallback(
		func(ctx context.Context, input interfaces.GetTaskExecutionInput) (models.TaskExecution, error) {
			return models.TaskExecution{
				BaseModel: models.BaseModel{
					ID: uint(8),
				},
			}, nil
		})
	repository.NodeExecutionRepo().(*repositoryMocks.MockNodeExecutionRepo).SetListCallback(
		func(ctx context.Context, input interfaces.ListResourceInput) (
			interfaces.NodeExecutionCollectionOutput, error) {
			assert.Equal(t, 1, input.Limit)
			assert.Equal(t, 2, input.Offset)
			assert.Len(t, input.InlineFilters, 4)
			assert.Equal(t, common.Execution, input.InlineFilters[0].GetEntity())
			queryExpr, _ := input.InlineFilters[0].GetGormQueryExpr()
			assert.Equal(t, "project", queryExpr.Args)
			assert.Equal(t, "execution_project = ?", queryExpr.Query)

			assert.Equal(t, common.Execution, input.InlineFilters[1].GetEntity())
			queryExpr, _ = input.InlineFilters[1].GetGormQueryExpr()
			assert.Equal(t, "domain", queryExpr.Args)
			assert.Equal(t, "execution_domain = ?", queryExpr.Query)

			assert.Equal(t, common.Execution, input.InlineFilters[2].GetEntity())
			queryExpr, _ = input.InlineFilters[2].GetGormQueryExpr()
			assert.Equal(t, "name", queryExpr.Args)
			assert.Equal(t, "execution_name = ?", queryExpr.Query)

			assert.Equal(t, common.NodeExecution, input.InlineFilters[3].GetEntity())
			queryExpr, _ = input.InlineFilters[3].GetGormQueryExpr()
			assert.Equal(t, uint(8), queryExpr.Args)
			assert.Equal(t, "parent_task_execution_id = ?", queryExpr.Query)

			assert.Equal(t, "domain asc", input.SortParameter.GetGormOrderExpr())
			return interfaces.NodeExecutionCollectionOutput{
				NodeExecutions: []models.NodeExecution{
					{
						NodeExecutionKey: models.NodeExecutionKey{
							NodeID: "node id",
							ExecutionKey: models.ExecutionKey{
								Project: "project",
								Domain:  "domain",
								Name:    "name",
							},
						},
						Phase:     core.NodeExecution_SUCCEEDED.String(),
						InputURI:  "input uri",
						StartedAt: &occurredAt,
						Closure:   closureBytes,
					},
				},
			}, nil
		})
	nodeExecManager := NewNodeExecutionManager(repository, mockScope.NewTestScope(), mockNodeExecutionRemoteURL)
	nodeExecutions, err := nodeExecManager.ListNodeExecutionsForTask(context.Background(), admin.NodeExecutionForTaskListRequest{
		TaskExecutionId: &core.TaskExecutionIdentifier{
			NodeExecutionId: &core.NodeExecutionIdentifier{
				ExecutionId: &core.WorkflowExecutionIdentifier{
					Project: "project",
					Domain:  "domain",
					Name:    "name",
				},
				NodeId: "node_id",
			},
			TaskId: &core.Identifier{
				ResourceType: core.ResourceType_TASK,
				Project:      "project",
				Domain:       "domain",
				Name:         "name",
				Version:      "version",
			},
		},
		Limit: 1,
		Token: "2",
		SortBy: &admin.Sort{
			Direction: admin.Sort_ASCENDING,
			Key:       "domain",
		},
	})
	assert.Nil(t, err)
	assert.Len(t, nodeExecutions.NodeExecutions, 1)
	assert.True(t, proto.Equal(&admin.NodeExecution{
		Id: &core.NodeExecutionIdentifier{
			NodeId: "node id",
			ExecutionId: &core.WorkflowExecutionIdentifier{
				Project: "project",
				Domain:  "domain",
				Name:    "name",
			},
		},
		InputUri: "input uri",
		Closure:  &expectedClosure,
	}, nodeExecutions.NodeExecutions[0]))
	assert.Equal(t, "3", nodeExecutions.Token)
}

func TestGetNodeExecutionData(t *testing.T) {
	repository := repositoryMocks.NewMockRepository()
	expectedClosure := admin.NodeExecutionClosure{
		Phase: core.NodeExecution_SUCCEEDED,
		OutputResult: &admin.NodeExecutionClosure_OutputUri{
			OutputUri: "output uri",
		},
	}
	closureBytes, _ := proto.Marshal(&expectedClosure)
	repository.NodeExecutionRepo().(*repositoryMocks.MockNodeExecutionRepo).SetGetCallback(
		func(ctx context.Context, input interfaces.GetNodeExecutionInput) (models.NodeExecution, error) {
			workflowExecutionIdentifier := core.WorkflowExecutionIdentifier{
				Project: "project",
				Domain:  "domain",
				Name:    "name",
			}
			assert.True(t, proto.Equal(&core.NodeExecutionIdentifier{
				NodeId:      "node id",
				ExecutionId: &workflowExecutionIdentifier,
			}, &input.NodeExecutionIdentifier))
			return models.NodeExecution{
				NodeExecutionKey: models.NodeExecutionKey{
					NodeID: "node id",
					ExecutionKey: models.ExecutionKey{
						Project: "project",
						Domain:  "domain",
						Name:    "name",
					},
				},
				Phase:     core.NodeExecution_SUCCEEDED.String(),
				InputURI:  "input uri",
				StartedAt: &occurredAt,
				Closure:   closureBytes,
			}, nil
		})

	mockNodeExecutionRemoteURL := dataMocks.NewMockRemoteURL()
	mockNodeExecutionRemoteURL.(*dataMocks.MockRemoteURL).GetCallback = func(ctx context.Context, uri string) (admin.UrlBlob, error) {
		if uri == "input uri" {
			return admin.UrlBlob{
				Url:   "inputs",
				Bytes: 100,
			}, nil
		} else if uri == "output uri" {
			return admin.UrlBlob{
				Url:   "outputs",
				Bytes: 200,
			}, nil
		}

		return admin.UrlBlob{}, errors.New("unexpected input")
	}
	nodeExecManager := NewNodeExecutionManager(repository, mockScope.NewTestScope(), mockNodeExecutionRemoteURL)
	dataResponse, err := nodeExecManager.GetNodeExecutionData(context.Background(), admin.NodeExecutionGetDataRequest{
		Id: &nodeExecutionIdentifier,
	})
	assert.Nil(t, err)
	assert.True(t, proto.Equal(&admin.NodeExecutionGetDataResponse{
		Inputs: &admin.UrlBlob{
			Url:   "inputs",
			Bytes: 100,
		},
		Outputs: &admin.UrlBlob{
			Url:   "outputs",
			Bytes: 200,
		},
	}, dataResponse))
}
