
  module "grafana"  {
    values  {
      
    }
    wait = true
    layer_name = "flyte-ap-south-1"
    create_namespace = true
    atomic = true
    chart_version = "0.33"
    dependency_update = 
    max_history = 16
    timeout = 23
    version = "0.0.1"
    repository = "https://grafana.github.io/helm-charts"
    wait_for_jobs = true
    env_name = "flyte-ap-south-1"
    cleanup_on_fail = true
    values_files = [
      
    ]
    source = "tqindia/cops/cloud/module/grafana"
  }
