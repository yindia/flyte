
  module "karpenter"  {
    source = "tqindia/cops/cloud/module/aws_karpenter"
    repository = "oci://public.ecr.aws/karpenter/karpenter"
    values_files = [
      
    ]
    dependency_update = 
    layer_name = "flyte-ap-south-1"
    atomic = true
    timeout = 23
    wait = true
    wait_for_jobs = true
    max_history = 16
    version = "0.0.1"
    create_namespace = true
    cleanup_on_fail = true
    chart_version = "0.37.0"
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
    env_name = "flyte-ap-south-1"
  }
