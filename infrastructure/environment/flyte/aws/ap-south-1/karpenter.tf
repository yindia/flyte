
  module "karpenter"  {
    max_history = 16
    wait = true
    env_name = "flyte-ap-south-1"
    layer_name = "flyte-ap-south-1"
    version = "0.0.1"
    create_namespace = true
    values "settings"  {
      clusterName = "${module.k8scluster.k8s_cluster_name}"
      interruptionQueue = "${module.k8scluster.k8s_cluster_name}"
    }
    values "controller" "resources"  {
      requests  {
        memory = "1Gi"
        cpu = 1
      }
      limits  {
        cpu = 1
        memory = "1Gi"
      }
    }
    dependency_update = 
    source = "tqindia/cops/cloud/module/aws_karpenter"
    repository = "oci://public.ecr.aws/karpenter/karpenter"
    values_files = [
      
    ]
    timeout = 23
    wait_for_jobs = true
    atomic = true
    cleanup_on_fail = true
    chart_version = "0.37.0"
  }
