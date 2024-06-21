
  module "k8scluster"  {
    kms_account_key_arn = "${module.base.kms_account_key_arn}"
    env_name = "flyte-ap-south-1"
    version = "0.0.1"
    ami_type = "AL2_x86_64"
    eks_log_retention = 60
    min_nodes = 3
    node_disk_size = 100
    enable_metrics = true
    spot_instances = true
    source = "tqindia/cops/cloud/module/aws_eks"
    node_instance_type = "t3.medium"
    node_launch_template  {
      
    }
    private_subnet_ids = "${module.base.private_subnet_ids}"
    vpc_id = "${module.base.vpc_id}"
    GPU = 
    cluster_name = "flyte-cluster"
    control_plane_security_groups = [
      
    ]
    k8s_version = "1.26"
    max_nodes = 10
    layer_name = "flyte-ap-south-1"
  }
