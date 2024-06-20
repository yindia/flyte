
  module "postgres"  {
    engine_version = "16.1"
    create_global_database = 
    database_name = "flyte"
    restore_from_snapshot = 
    env_name = "flyte-ap-south-1"
    layer_name = "flyte-ap-south-1"
    safety = true
    multi_az = true
    backup_retention_days = 60
    source = "tqindia/cops/cloud/module/aws_postgres"
    version = "0.0.1"
    instance_class = "db.t3.medium"
    existing_global_database_id = 
    extra_security_groups_ids = [
      
    ]
  }
