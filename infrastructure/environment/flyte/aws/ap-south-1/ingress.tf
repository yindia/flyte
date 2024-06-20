
  module "ingress"  {
    cleanup_on_fail = true
    values  {
      
    }
    wait = true
    env_name = "flyte-ap-south-1"
    timeout = 23
    dependency_update = 
    max_history = 16
    source = "tqindia/cops/cloud/module/ingress"
    create_namespace = true
    values_files = [
      
    ]
    layer_name = "flyte-ap-south-1"
    repository = "https://kubernetes.github.io/ingress-nginx"
    atomic = true
    chart_version = "4.10.1"
    wait_for_jobs = true
    version = "0.0.1"
  }
