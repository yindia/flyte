
  module "postgres"  {
    source = "tqindia/cops/cloud/module/aws_postgres"
    version = "0.0.1"
    restore_from_snapshot = 
    instance_class = "db.t3.medium"
    safety = true
    backup_retention_days = 60
    engine_version = "16.1"
    create_global_database = 
    layer_name = "flyte-ap-south-1"
    database_name = "flyte"
    env_name = "flyte-ap-south-1"
    multi_az = true
    extra_security_groups_ids = [
      
    ]
    existing_global_database_id = 
  }
