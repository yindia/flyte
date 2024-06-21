
  module "s3"  {
    bucket_name = "flyte-storage"
    cors_rule = [
      {
        allowed_origins = [
          "thecops.dev"
        ]
        methods = [
          "POST",
          "PUT",
          "DELETE"
        ]
        max_age_seconds = "122"
      }
    ]
    s3_log_bucket_name = 
    source = "tqindia/cops/cloud/module/aws_s3"
    layer_name = "flyte-ap-south-1"
    same_region_replication = true
    block_public = true
    bucket_policy  {
      
    }
    cors_enabled = true
    files = 
    env_name = "flyte-ap-south-1"
    version = "0.0.1"
  }
