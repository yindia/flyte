
  module "karpenter"  {
    create_namespace = true
    cleanup_on_fail = true
    wait = true
    layer_name = "flyte-ap-south-1"
    source = "tqindia/cops/cloud/module/aws_karpenter"
    repository = "oci://public.ecr.aws/karpenter/karpenter"
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
    chart_version = "0.37.0"
    values_files = [
      
    ]
    max_history = 16
    dependency_update = 
    wait_for_jobs = true
    env_name = "flyte-ap-south-1"
    version = "0.0.1"
    atomic = true
    timeout = 23
  }
