
  module "schedulesQueue"  {
    delay_seconds = 
    source = "tqindia/cops/cloud/module/aws_sqs"
    fifo = 
    content_based_deduplication = 
    env_name = "flyte-ap-south-1"
    layer_name = "flyte-ap-south-1"
    version = "0.0.1"
    message_retention_seconds = 345600
    receive_wait_time_seconds = 
  }
