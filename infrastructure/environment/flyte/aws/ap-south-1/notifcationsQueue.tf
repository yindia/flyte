
  module "notifcationsQueue"  {
    env_name = "flyte-ap-south-1"
    layer_name = "flyte-ap-south-1"
    source = "tqindia/cops/cloud/module/aws_sqs"
    fifo = 
    receive_wait_time_seconds = 
    message_retention_seconds = 345600
    version = "0.0.1"
    content_based_deduplication = 
    delay_seconds = 
  }