
  module "s3"  {
    bucket_policy = 
    env_name = "flyte-ap-south-1"
    layer_name = "flyte-ap-south-1"
    s3_log_bucket_name = 
    source = "tqindia/cops/cloud/module/aws_s3"
    version = "0.0.1"
    bucket_name = "flyte-storage"
    same_region_replication = true
    block_public = true
    cors_enabled = 
    cors_rule = [
      
    ]
    files = 
  }
