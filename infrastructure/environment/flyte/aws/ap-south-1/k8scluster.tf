
  module "k8scluster"  {
    node_disk_size = 100
    node_launch_template  {
      
    }
    layer_name = "flyte-ap-south-1"
    control_plane_security_groups = [
      
    ]
    enable_metrics = true
    min_nodes = 3
    kms_account_key_arn = "${module.base.kms_account_key_arn}"
    env_name = "flyte-ap-south-1"
    source = "tqindia/cops/cloud/module/aws_eks"
    max_nodes = 10
    node_instance_type = "t3.medium"
    private_subnet_ids = "${module.base.private_subnet_ids}"
    version = "0.0.1"
    cluster_name = "flyte-cluster"
    eks_log_retention = 60
    k8s_version = "1.26"
    vpc_id = "${module.base.vpc_id}"
    GPU = 
    ami_type = "AL2_x86_64"
    spot_instances = true
  }
