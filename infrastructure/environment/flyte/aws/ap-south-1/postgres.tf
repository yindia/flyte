
  module "postgres"  {
    database_name = "flyte"
    restore_from_snapshot = 
    source = "tqindia/cops/cloud/module/aws_postgres"
    engine_version = "16.1"
    extra_security_groups_ids = [
      
    ]
    instance_class = "db.t3.medium"
    create_global_database = 
    env_name = "flyte-ap-south-1"
    version = "0.0.1"
    safety = true
    backup_retention_days = 60
    layer_name = "flyte-ap-south-1"
    multi_az = true
    existing_global_database_id = 
  }
