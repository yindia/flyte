
  module "dns"  {
    delegated = 
    env_name = "flyte-ap-south-1"
    layer_name = "flyte-ap-south-1"
    domain = "flyte.thecops.dev"
    source = "tqindia/cops/cloud/module/aws_dns"
    version = "0.0.1"
  }
