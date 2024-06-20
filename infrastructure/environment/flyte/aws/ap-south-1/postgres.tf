
  module "postgres"  {
    extra_security_groups_ids = [
      
    ]
    backup_retention_days = 60
    multi_az = true
    restore_from_snapshot = 
    source = "tqindia/cops/cloud/module/aws_postgres"
    instance_class = "db.t3.medium"
    engine_version = "17 Beta 1"
    existing_global_database_id = 
    database_name = "flyte"
    env_name = "flyte-ap-south-1"
    layer_name = "flyte-ap-south-1"
    version = "0.0.1"
    safety = true
    create_global_database = 
  }
