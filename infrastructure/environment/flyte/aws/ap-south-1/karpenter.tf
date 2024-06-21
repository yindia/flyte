
  module "karpenter"  {
    chart_version = "0.37.0"
    wait_for_jobs = true
    create_namespace = true
    cleanup_on_fail = true
    values "settings"  {
      clusterName = "${module.k8scluster.k8s_cluster_name}"
      interruptionQueue = "${module.k8scluster.k8s_cluster_name}"
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
    wait = true
    max_history = 16
    version = "0.0.1"
    repository = "oci://public.ecr.aws/karpenter/karpenter"
    atomic = true
    dependency_update = 
    env_name = "flyte-ap-south-1"
    layer_name = "flyte-ap-south-1"
    source = "tqindia/cops/cloud/module/aws_karpenter"
    values_files = [
      
    ]
    timeout = 23
  }
