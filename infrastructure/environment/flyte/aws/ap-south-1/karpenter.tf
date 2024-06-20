
  module "karpenter"  {
    env_name = "flyte-ap-south-1"
    layer_name = "flyte-ap-south-1"
    atomic = true
    values_files = [
      
    ]
    wait = true
    max_history = 16
    wait_for_jobs = true
    source = "tqindia/cops/cloud/module/aws_karpenter"
    version = "0.0.1"
    repository = "oci://public.ecr.aws/karpenter/karpenter"
    create_namespace = true
    chart_version = "0.37.0"
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
        memory = "1Gi"
        cpu = 1
      }
    }
    timeout = 23
    dependency_update = 
  }
