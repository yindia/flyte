
  module "schedulesQueue"  {
    env_name = "flyte-ap-south-1"
    fifo = 
    delay_seconds = 
    receive_wait_time_seconds = 
    source = "tqindia/cops/cloud/module/aws_sqs"
    version = "0.0.1"
    content_based_deduplication = 
    message_retention_seconds = 345600
    layer_name = "flyte-ap-south-1"
  }
