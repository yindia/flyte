
  module "s3"  {
    files = 
    version = "0.0.1"
    bucket_name = "flyte-storage"
    same_region_replication = true
    block_public = true
    bucket_policy = 
    cors_rule = [
      
    ]
    source = "tqindia/cops/cloud/module/aws_s3"
    cors_enabled = 
    env_name = "flyte-ap-south-1"
    layer_name = "flyte-ap-south-1"
    s3_log_bucket_name = 
  }
