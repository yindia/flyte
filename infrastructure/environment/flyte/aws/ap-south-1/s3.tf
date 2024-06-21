
  module "s3"  {
    cors_enabled = true
    files = 
    env_name = "flyte-ap-south-1"
    s3_log_bucket_name = 
    source = "tqindia/cops/cloud/module/aws_s3"
    bucket_name = "flyte-storage"
    same_region_replication = true
    version = "0.0.1"
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
    layer_name = "flyte-ap-south-1"
    block_public = true
    bucket_policy  {
      
    }
  }
