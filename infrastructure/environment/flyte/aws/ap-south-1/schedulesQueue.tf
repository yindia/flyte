
  module "schedulesQueue"  {
    version = "0.0.1"
    delay_seconds = 
    layer_name = "flyte-ap-south-1"
    receive_wait_time_seconds = 
    env_name = "flyte-ap-south-1"
    source = "tqindia/cops/cloud/module/aws_sqs"
    fifo = 
    content_based_deduplication = 
    message_retention_seconds = 345600
  }
