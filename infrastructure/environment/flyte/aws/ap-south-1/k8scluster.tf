
  module "k8scluster"  {
    spot_instances = true
    node_disk_size = 100
    env_name = "flyte-ap-south-1"
    source = "tqindia/cops/cloud/module/aws_eks"
    eks_log_retention = 60
    k8s_version = "1.26"
    min_nodes = 3
    node_instance_type = "t3.medium"
    node_launch_template  {
      
    }
    private_subnet_ids = "${module.base.private_subnet_ids}"
    vpc_id = "${module.base.vpc_id}"
    ami_type = "AL2_x86_64"
    cluster_name = "flyte-cluster"
    control_plane_security_groups = [
      
    ]
    max_nodes = 10
    GPU = 
    layer_name = "flyte-ap-south-1"
    enable_metrics = true
    kms_account_key_arn = "${module.base.kms_account_key_arn}"
    version = "0.0.1"
  }
