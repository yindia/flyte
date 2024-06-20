
  module "ingress"  {
    wait = true
    atomic = true
    chart_version = "4.10.1"
    values  {
      
    }
    timeout = 23
    dependency_update = 
    repository = "https://kubernetes.github.io/ingress-nginx"
    cleanup_on_fail = true
    max_history = 16
    version = "0.0.1"
    create_namespace = true
    values_files = [
      
    ]
    wait_for_jobs = true
    env_name = "flyte-ap-south-1"
    layer_name = "flyte-ap-south-1"
    source = "tqindia/cops/cloud/module/ingress"
  }
