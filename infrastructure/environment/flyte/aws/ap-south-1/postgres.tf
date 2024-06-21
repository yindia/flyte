
  module "postgres"  {
    existing_global_database_id = 
    database_name = "flyte"
    multi_az = true
    safety = true
    backup_retention_days = 60
    extra_security_groups_ids = [
      
    ]
    source = "tqindia/cops/cloud/module/aws_postgres"
    instance_class = "db.t3.medium"
    engine_version = "17 Beta 1"
    layer_name = "flyte-ap-south-1"
    env_name = "flyte-ap-south-1"
    version = "0.0.1"
    create_global_database = 
    restore_from_snapshot = 
  }
