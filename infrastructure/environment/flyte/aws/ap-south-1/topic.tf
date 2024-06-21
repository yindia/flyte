
  module "topic"  {
    fifo = 
    content_based_deduplication = 
    sqs_subscribers = [
      "${module.notifcationsQueue.queue_arn}"
    ]
    env_name = "flyte-ap-south-1"
    layer_name = "flyte-ap-south-1"
    source = "tqindia/cops/cloud/module/aws_sns"
    version = "0.0.1"
  }
