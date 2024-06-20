
  module "s3"  {
    bucket_name = "flyte-storage"
    same_region_replication = true
    bucket_policy  {
      
    }
    files = 
    version = "0.0.1"
    source = "tqindia/cops/cloud/module/aws_s3"
    block_public = true
    cors_enabled = true
    cors_rule = [
      {
        methods = [
          "POST",
          "PUT",
          "DELETE"
        ]
        max_age_seconds = "122"
        allowed_origins = [
          "thecops.dev"
        ]
      }
    ]
    env_name = "flyte-ap-south-1"
    layer_name = "flyte-ap-south-1"
    s3_log_bucket_name = 
  }
