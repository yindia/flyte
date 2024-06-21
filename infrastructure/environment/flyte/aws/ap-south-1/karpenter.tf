
  module "karpenter"  {
    cleanup_on_fail = true
    values "settings"  {
      interruptionQueue = "${module.k8scluster.k8s_cluster_name}"
      clusterName = "${module.k8scluster.k8s_cluster_name}"
    }
    values "controller" "resources"  {
      requests  {
        cpu = 1
        memory = "1Gi"
      }
      limits  {
        cpu = 1
        memory = "1Gi"
      }
    }
    max_history = 16
    version = "0.0.1"
    repository = "oci://public.ecr.aws/karpenter/karpenter"
    atomic = true
    env_name = "flyte-ap-south-1"
    source = "tqindia/cops/cloud/module/aws_karpenter"
    dependency_update = 
    layer_name = "flyte-ap-south-1"
    create_namespace = true
    chart_version = "0.37.0"
    values_files = [
      
    ]
    timeout = 23
    wait = true
    wait_for_jobs = true
  }
