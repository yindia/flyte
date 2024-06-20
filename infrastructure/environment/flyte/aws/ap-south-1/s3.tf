
  module "s3"  {
    env_name = "flyte-ap-south-1"
    s3_log_bucket_name = 
    source = "tqindia/cops/cloud/module/aws_s3"
    version = "0.0.1"
    block_public = true
    bucket_policy = 
    cors_rule = [
      
    ]
    files = 
    layer_name = "flyte-ap-south-1"
    bucket_name = "flyte-storage"
    same_region_replication = true
    cors_enabled = 
  }
