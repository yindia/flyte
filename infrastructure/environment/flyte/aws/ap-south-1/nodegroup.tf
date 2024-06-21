
  module "nodegroup"  {
    max_nodes = 15
    env_name = "flyte-ap-south-1"
    layer_name = "flyte-ap-south-1"
    ami_type = "AL2_x86_64"
    node_disk_size = 100
    node_instance_type = "t3.medium"
    taints = [
      {
        effect = "NoEffect"
        key = "team"
        value = "mlops"
      },
      {
        key = "team"
        value = "mlops"
        effect = "None"
      },
      {
        key = "mlops"
        value = 
        effect = "NoEffect"
      }
    ]
    version = "0.0.1"
    use_gpu = true
    source = "tqindia/cops/cloud/module/aws_nodegroup"
    labels = [
      {
        key = "team"
        value = "booking"
      }
    ]
    min_nodes = 3
    spot_instances = 
  }
