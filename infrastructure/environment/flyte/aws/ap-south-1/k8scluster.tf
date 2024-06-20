
  module "k8scluster"  {
    vpc_id = "${module.base.vpc_id}"
    env_name = "flyte-ap-south-1"
    layer_name = "flyte-ap-south-1"
    min_nodes = 3
    node_launch_template  {
      
    }
    eks_log_retention = 60
    k8s_version = "1.26"
    spot_instances = true
    GPU = 
    version = "0.0.1"
    ami_type = "AL2_x86_64"
    cluster_name = "flyte-cluster"
    kms_account_key_arn = "${module.base.kms_account_key_arn}"
    private_subnet_ids = "${module.base.private_subnet_ids}"
    control_plane_security_groups = [
      
    ]
    enable_metrics = true
    node_instance_type = "t3.medium"
    source = "tqindia/cops/cloud/module/aws_eks"
    max_nodes = 10
    node_disk_size = 100
  }
