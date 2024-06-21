
  module "postgres"  {
    multi_az = true
    safety = true
    extra_security_groups_ids = [
      
    ]
    engine_version = "17 Beta 1"
    backup_retention_days = 60
    database_name = "flyte"
    env_name = "flyte-ap-south-1"
    version = "0.0.1"
    create_global_database = 
    existing_global_database_id = 
    layer_name = "flyte-ap-south-1"
    instance_class = "db.t3.medium"
    restore_from_snapshot = 
    source = "tqindia/cops/cloud/module/aws_postgres"
  }
