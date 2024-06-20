
  module "linkerd"  {
    wait_for_jobs = true
    max_history = 16
    env_name = "flyte-ap-south-1"
    layer_name = "flyte-ap-south-1"
    source = "tqindia/cops/cloud/module/linkerd"
    dependency_update = 
    atomic = true
    values_files = [
      
    ]
    values  {
      clusterName = "${module.k8scluster.k8s_cluster_name}"
    }
    wait = true
    version = "0.0.1"
    create_namespace = true
    timeout = 23
    chart_version = "2.11.5"
    repository = "https://helm.linkerd.io/edge"
    cleanup_on_fail = true
  }
