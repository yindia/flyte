
  module "nodegroup"  {
    labels = [
      {
        key = "team"
        value = "booking"
      }
    ]
    min_nodes = 3
    max_nodes = 15
    env_name = "flyte-ap-south-1"
    source = "tqindia/cops/cloud/module/aws_nodegroup"
    version = "0.0.1"
    node_instance_type = "t3.medium"
    use_gpu = true
    layer_name = "flyte-ap-south-1"
    ami_type = "AL2_x86_64"
    node_disk_size = 100
    spot_instances = 
    taints = [
      {
        value = "mlops"
        effect = "NoEffect"
        key = "team"
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
  }
