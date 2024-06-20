
  module "postgres"  {
    instance_class = "db.t3.medium"
    engine_version = "16.1"
    backup_retention_days = 60
    existing_global_database_id = 
    multi_az = true
    source = "tqindia/cops/cloud/module/aws_postgres"
    safety = true
    extra_security_groups_ids = [
      
    ]
    create_global_database = 
    env_name = "flyte-ap-south-1"
    layer_name = "flyte-ap-south-1"
    version = "0.0.1"
    database_name = "flyte"
    restore_from_snapshot = 
  }
