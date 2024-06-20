
  module "k8scluster"  {
    node_disk_size = 100
    control_plane_security_groups = [
      
    ]
    max_nodes = 10
    min_nodes = 3
    env_name = "flyte-ap-south-1"
    enable_metrics = true
    spot_instances = true
    private_subnet_ids = "${module.base.private_subnet_ids}"
    vpc_id = "${module.base.vpc_id}"
    GPU = 
    layer_name = "flyte-ap-south-1"
    version = "0.0.1"
    cluster_name = "flyte-cluster"
    k8s_version = "1.26"
    kms_account_key_arn = "${module.base.kms_account_key_arn}"
    node_launch_template  {
      
    }
    source = "tqindia/cops/cloud/module/aws_eks"
    ami_type = "AL2_x86_64"
    eks_log_retention = 60
    node_instance_type = "t3.medium"
  }
