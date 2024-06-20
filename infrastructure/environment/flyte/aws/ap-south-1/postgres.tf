
  module "postgres"  {
    safety = true
    extra_security_groups_ids = [
      
    ]
    create_global_database = 
    version = "0.0.1"
    instance_class = "db.t3.medium"
    multi_az = true
    backup_retention_days = 60
    source = "tqindia/cops/cloud/module/aws_postgres"
    existing_global_database_id = 
    env_name = "flyte-ap-south-1"
    layer_name = "flyte-ap-south-1"
    engine_version = "16.1"
    database_name = "flyte"
    restore_from_snapshot = 
  }
