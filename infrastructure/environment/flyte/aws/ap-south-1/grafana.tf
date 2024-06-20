
  module "grafana"  {
    env_name = "flyte-ap-south-1"
    atomic = true
    dependency_update = 
    wait = true
    wait_for_jobs = true
    max_history = 16
    create_namespace = true
    values  {
      
    }
    cleanup_on_fail = true
    values_files = [
      
    ]
    version = "0.0.1"
    repository = "https://grafana.github.io/helm-charts"
    chart_version = "0.33"
    timeout = 23
    layer_name = "flyte-ap-south-1"
    source = "tqindia/cops/cloud/module/grafana"
  }
