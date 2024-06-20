
  module "ingress"  {
    values  {
      
    }
    wait_for_jobs = true
    max_history = 16
    version = "0.0.1"
    repository = "https://kubernetes.github.io/ingress-nginx"
    create_namespace = true
    values_files = [
      
    ]
    wait = true
    env_name = "flyte-ap-south-1"
    cleanup_on_fail = true
    timeout = 23
    layer_name = "flyte-ap-south-1"
    atomic = true
    chart_version = "4.10.1"
    dependency_update = 
    source = "tqindia/cops/cloud/module/ingress"
  }
