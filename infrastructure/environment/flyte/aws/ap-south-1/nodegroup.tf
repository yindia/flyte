
  module "nodegroup"  {
    node_instance_type = "t3.medium"
    use_gpu = true
    env_name = "flyte-ap-south-1"
    spot_instances = 
    source = "tqindia/cops/cloud/module/aws_nodegroup"
    labels = [
      {
        key = "team"
        value = "booking"
      }
    ]
    min_nodes = 3
    taints = [
      {
        key = "team"
        value = "mlops"
        effect = "NoEffect"
      },
      {
        value = "mlops"
        effect = "None"
        key = "team"
      },
      {
        key = "mlops"
        value = 
        effect = "NoEffect"
      }
    ]
    ami_type = "AL2_x86_64"
    max_nodes = 15
    node_disk_size = 100
    layer_name = "flyte-ap-south-1"
    version = "0.0.1"
  }
