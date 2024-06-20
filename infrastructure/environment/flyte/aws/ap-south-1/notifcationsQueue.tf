
  module "notifcationsQueue"  {
    receive_wait_time_seconds = 
    env_name = "flyte-ap-south-1"
    version = "0.0.1"
    content_based_deduplication = 
    delay_seconds = 
    layer_name = "flyte-ap-south-1"
    source = "tqindia/cops/cloud/module/aws_sqs"
    fifo = 
    message_retention_seconds = 345600
  }
