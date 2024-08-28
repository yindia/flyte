
  module "grafana"  {
    create_namespace = true
    wait_for_jobs = true
    version = "0.0.1"
    atomic = true
    cleanup_on_fail = true
    chart_version = "0.33"
    dependency_update = 
    env_name = "flyte-ap-south-1"
    repository = "https://grafana.github.io/helm-charts"
    values  {
      
    }
    timeout = 23
    wait = true
    layer_name = "flyte-ap-south-1"
    values_files = [
      
    ]
    max_history = 16
    source = "tqindia/cops/cloud/module/grafana"
  }
