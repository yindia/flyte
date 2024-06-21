
  module "k8scluster"  {
    source = "tqindia/cops/cloud/module/aws_eks"
    version = "0.0.1"
    enable_metrics = true
    node_disk_size = 100
    node_instance_type = "t3.medium"
    private_subnet_ids = "${module.base.private_subnet_ids}"
    GPU = 
    layer_name = "flyte-ap-south-1"
    cluster_name = "flyte-cluster"
    k8s_version = "1.26"
    min_nodes = 3
    node_launch_template  {
      
    }
    spot_instances = true
    vpc_id = "${module.base.vpc_id}"
    control_plane_security_groups = [
      
    ]
    eks_log_retention = 60
    max_nodes = 10
    kms_account_key_arn = "${module.base.kms_account_key_arn}"
    ami_type = "AL2_x86_64"
    env_name = "flyte-ap-south-1"
  }
