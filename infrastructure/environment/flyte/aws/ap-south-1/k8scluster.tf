
  module "k8scluster"  {
    control_plane_security_groups = [
      
    ]
    enable_metrics = true
    node_launch_template  {
      
    }
    env_name = "flyte-ap-south-1"
    version = "0.0.1"
    ami_type = "AL2_x86_64"
    max_nodes = 10
    node_disk_size = 100
    kms_account_key_arn = "${module.base.kms_account_key_arn}"
    vpc_id = "${module.base.vpc_id}"
    layer_name = "flyte-ap-south-1"
    eks_log_retention = 60
    k8s_version = "1.26"
    spot_instances = true
    cluster_name = "flyte-cluster"
    min_nodes = 3
    node_instance_type = "t3.medium"
    private_subnet_ids = "${module.base.private_subnet_ids}"
    GPU = 
    source = "tqindia/cops/cloud/module/aws_eks"
  }
