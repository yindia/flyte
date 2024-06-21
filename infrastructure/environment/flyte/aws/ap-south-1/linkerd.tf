
  module "linkerd"  {
    max_history = 16
    version = "0.0.1"
    dependency_update = 
    wait = true
    wait_for_jobs = true
    layer_name = "flyte-ap-south-1"
    create_namespace = true
    cleanup_on_fail = true
    timeout = 23
    values_files = [
      
    ]
    source = "tqindia/cops/cloud/module/linkerd"
    repository = "https://helm.linkerd.io/edge"
    atomic = true
    chart_version = "2.11.5"
    env_name = "flyte-ap-south-1"
    values  {
      clusterName = "${module.k8scluster.k8s_cluster_name}"
    }
  }
