
  module "schedulesQueue"  {
    fifo = 
    delay_seconds = 
    message_retention_seconds = 345600
    source = "tqindia/cops/cloud/module/aws_sqs"
    version = "0.0.1"
    content_based_deduplication = 
    receive_wait_time_seconds = 
    env_name = "flyte-ap-south-1"
    layer_name = "flyte-ap-south-1"
  }
