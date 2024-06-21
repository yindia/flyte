
  module "postgres"  {
    multi_az = true
    instance_class = "db.t3.medium"
    backup_retention_days = 60
    create_global_database = 
    existing_global_database_id = 
    engine_version = "17 Beta 1"
    extra_security_groups_ids = [
      
    ]
    database_name = "flyte"
    restore_from_snapshot = 
    env_name = "flyte-ap-south-1"
    layer_name = "flyte-ap-south-1"
    source = "tqindia/cops/cloud/module/aws_postgres"
    version = "0.0.1"
    safety = true
  }
