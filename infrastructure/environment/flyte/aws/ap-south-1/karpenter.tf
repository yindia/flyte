
  module "karpenter"  {
    source = "tqindia/cops/cloud/module/aws_karpenter"
    repository = "oci://public.ecr.aws/karpenter/karpenter"
    create_namespace = true
    atomic = true
    wait_for_jobs = true
    layer_name = "flyte-ap-south-1"
    max_history = 16
    chart_version = "0.37.0"
    values_files = [
      
    ]
    timeout = 23
    wait = true
    dependency_update = 
    version = "0.0.1"
    cleanup_on_fail = true
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
    values "settings"  {
      clusterName = "${module.k8scluster.k8s_cluster_name}"
      interruptionQueue = "${module.k8scluster.k8s_cluster_name}"
    }
    env_name = "flyte-ap-south-1"
  }
