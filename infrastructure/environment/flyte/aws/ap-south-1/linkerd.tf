
  module "linkerd"  {
    values_files = [
      
    ]
    timeout = 23
    repository = "https://helm.linkerd.io/edge"
    atomic = true
    values  {
      clusterName = "${module.k8scluster.k8s_cluster_name}"
    }
    wait_for_jobs = true
    version = "0.0.1"
    create_namespace = true
    env_name = "flyte-ap-south-1"
    source = "tqindia/cops/cloud/module/linkerd"
    cleanup_on_fail = true
    wait = true
    max_history = 16
    layer_name = "flyte-ap-south-1"
    chart_version = "2.11.5"
    dependency_update = 
  }
