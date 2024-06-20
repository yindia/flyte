
  module "s3"  {
    same_region_replication = true
    block_public = true
    layer_name = "flyte-ap-south-1"
    s3_log_bucket_name = 
    source = "tqindia/cops/cloud/module/aws_s3"
    version = "0.0.1"
    bucket_name = "flyte-storage"
    bucket_policy = 
    cors_enabled = 
    cors_rule = [
      
    ]
    files = 
    env_name = "flyte-ap-south-1"
  }
