
  module "s3"  {
    s3_log_bucket_name = 
    block_public = true
    bucket_policy = 
    cors_enabled = 
    cors_rule = [
      
    ]
    files = 
    layer_name = "flyte-ap-south-1"
    source = "tqindia/cops/cloud/module/aws_s3"
    version = "0.0.1"
    bucket_name = "flyte-storage"
    same_region_replication = true
    env_name = "flyte-ap-south-1"
  }
