
  module "karpenter"  {
    values_files = [
      
    ]
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
    max_history = 16
    cleanup_on_fail = true
    env_name = "flyte-ap-south-1"
    timeout = 23
    dependency_update = 
    layer_name = "flyte-ap-south-1"
    version = "0.0.1"
    chart_version = "0.37.0"
    wait_for_jobs = true
    create_namespace = true
    atomic = true
    wait = true
    source = "tqindia/cops/cloud/module/aws_karpenter"
    repository = "oci://public.ecr.aws/karpenter/karpenter"
  }
