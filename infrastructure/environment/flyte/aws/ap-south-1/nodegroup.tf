
  module "nodegroup"  {
    max_nodes = 15
    min_nodes = 3
    node_disk_size = 100
    source = "tqindia/cops/cloud/module/aws_nodegroup"
    ami_type = "AL2_x86_64"
    node_instance_type = "t3.medium"
    taints = [
      {
        key = "team"
        value = "mlops"
        effect = "NoEffect"
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
    env_name = "flyte-ap-south-1"
    version = "0.0.1"
    labels = [
      {
        key = "team"
        value = "booking"
      }
    ]
    use_gpu = true
    spot_instances = 
    layer_name = "flyte-ap-south-1"
  }
