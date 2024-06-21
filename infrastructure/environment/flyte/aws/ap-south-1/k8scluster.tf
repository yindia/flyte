
  module "k8scluster"  {
    k8s_version = "1.26"
    source = "tqindia/cops/cloud/module/aws_eks"
    cluster_name = "flyte-cluster"
    max_nodes = 10
    kms_account_key_arn = "${module.base.kms_account_key_arn}"
    layer_name = "flyte-ap-south-1"
    version = "0.0.1"
    enable_metrics = true
    eks_log_retention = 60
    min_nodes = 3
    node_disk_size = 100
    vpc_id = "${module.base.vpc_id}"
    env_name = "flyte-ap-south-1"
    control_plane_security_groups = [
      
    ]
    node_instance_type = "t3.medium"
    node_launch_template  {
      
    }
    spot_instances = true
    private_subnet_ids = "${module.base.private_subnet_ids}"
    GPU = 
    ami_type = "AL2_x86_64"
  }
