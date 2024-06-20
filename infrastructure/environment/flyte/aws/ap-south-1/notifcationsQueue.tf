
  module "notifcationsQueue"  {
    content_based_deduplication = 
    message_retention_seconds = 345600
    receive_wait_time_seconds = 
    env_name = "flyte-ap-south-1"
    layer_name = "flyte-ap-south-1"
    version = "0.0.1"
    fifo = 
    delay_seconds = 
    source = "tqindia/cops/cloud/module/aws_sqs"
  }
