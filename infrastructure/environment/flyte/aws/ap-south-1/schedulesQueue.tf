
  module "schedulesQueue"  {
    content_based_deduplication = 
    delay_seconds = 
    env_name = "flyte-ap-south-1"
    layer_name = "flyte-ap-south-1"
    source = "tqindia/cops/cloud/module/aws_sqs"
    version = "0.0.1"
    fifo = 
    message_retention_seconds = 345600
    receive_wait_time_seconds = 
  }
