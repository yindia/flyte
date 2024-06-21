
  module "flyte-core"  {
    timeout = 23
    repository = "https://flyteorg.github.io/flyte"
    namespace = "flyte"
    chart_version = "0.33"
    source = "tqindia/cops/cloud/module/helm_chart"
    values "configuration" "database"  {
      password = "${module.postgres.db_password}"
      host = "${module.postgres.db_host}"
      dbname = "${module.postgres.db_name}"
      username = "${module.postgres.db_user}"
    }
    values "configuration" "storage"  {
      provider = "s3"
      providerConfig "s3"  {
        region = "<aws-region>"
        authType = "iam"
      }
      metadataContainer = "s3://${module.s3.bucket_arn}"
      userDataContainer = "s3://${module.adminflyterole.role_arn}"
    }
    values "configuration" "inline"  {
      task_resources "defaults"  {
        cpu = "100m"
        memory = "100Mi"
        storage = "100Mi"
      }
      task_resources "limits"  {
        memory = "1Gi"
      }
      cluster_resources  {
        customData = [
          {
            production = [
              {
                defaultIamRole = {
                  value = "arn:aws:iam::<AWS-ACCOUNT-ID>:role/flyte-workers-role"
                }
              }
            ]
          },
          {
            staging = [
              {
                defaultIamRole = {
                  value = "arn:aws:iam::<AWS-ACCOUNT-ID>:role/flyte-workers-role"
                }
              }
            ]
          },
          {
            development = [
              {
                defaultIamRole = {
                  value = "arn:aws:iam::<AWS-ACCOUNT-ID>:role/flyte-workers-role"
                }
              }
            ]
          }
        ]
      }
      plugins "k8s"  {
        inject-finalizer = true
        default-env-vars = [
          {
            AWS_METADATA_SERVICE_TIMEOUT = 5
          },
          {
            AWS_METADATA_SERVICE_NUM_ATTEMPTS = 20
          }
        ]
      }
      storage "cache"  {
        max_size_mbs = 10
        target_gc_percent = 100
      }
      tasks "task-plugins"  {
        enabled-plugins = [
          "container",
          "sidecar",
          "K8S-ARRAY"
        ]
        default-for-task-types = [
          {
            container = "container"
          },
          {
            container_array = "K8S-ARRAY"
          }
        ]
      }
    }
    values "clusterResourceTemplates" "inline"  {
      001_namespace.yaml = "apiVersion: v1
kind: Namespace
metadata:
  name: '{{ namespace }}'
"
      002_serviceaccount.yaml = "apiVersion: v1
kind: ServiceAccount
metadata:
  name: default
  namespace: '{{ namespace }}'
  annotations:
    eks.amazonaws.com/role-arn: '{{ defaultIamRole }}'
"
    }
    values "ingress"  {
      create = true
      commonAnnotations  {
        alb.ingress.kubernetes.io/ssl-redirect = "443"
        alb.ingress.kubernetes.io/target-type = "ip"
        kubernetes.io/ingress.class = "alb"
        alb.ingress.kubernetes.io/certificate-arn = "arn:aws:acm:<AWS-REGION>:<AWS-ACCOUNT-ID>:certificate/<CERTIFICATE-ID>"
        alb.ingress.kubernetes.io/group.name = "flyte"
        alb.ingress.kubernetes.io/listen-ports = "[{"HTTP": 80}, {"HTTPS":443}]"
        alb.ingress.kubernetes.io/scheme = "internet-facing"
      }
      httpAnnotations  {
        alb.ingress.kubernetes.io/actions.app-root = "{"Type": "redirect", "RedirectConfig": {"Path": "/console", "StatusCode": "HTTP_302"}}"
      }
      grpcAnnotations  {
        alb.ingress.kubernetes.io/backend-protocol-version = "GRPC"
      }
      host = "flyte-the-hard-way.uniondemo.run"
    }
    values "serviceAccount"  {
      create = true
      annotations  {
        eks.amazonaws.com/role-arn = "arn:aws:iam::<AWS-ACCOUNT-ID>:role/flyte-system-role"
      }
    }
    wait = true
    env_name = "flyte-ap-south-1"
    layer_name = "flyte-ap-south-1"
    values_files = [
      
    ]
    dependency_update = 
    wait_for_jobs = true
    version = "0.0.1"
    create_namespace = true
    atomic = true
    cleanup_on_fail = true
    max_history = 16
  }
