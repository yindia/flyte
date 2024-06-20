
  module "schedulesQueue"  {
    env_name = "flyte-ap-south-1"
    source = "tqindia/cops/cloud/module/aws_sqs"
    version = "0.0.1"
    message_retention_seconds = 345600
    content_based_deduplication = 
    delay_seconds = 
    receive_wait_time_seconds = 
    layer_name = "flyte-ap-south-1"
    fifo = 
  }
