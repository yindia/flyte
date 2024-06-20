
  module "k8scluster"  {
    k8s_version = "1.26"
    node_disk_size = 100
    node_launch_template  {
      
    }
    layer_name = "flyte-ap-south-1"
    source = "tqindia/cops/cloud/module/aws_eks"
    control_plane_security_groups = [
      
    ]
    eks_log_retention = 60
    enable_metrics = true
    max_nodes = 10
    min_nodes = 3
    kms_account_key_arn = "${module.base.kms_account_key_arn}"
    private_subnet_ids = "${module.base.private_subnet_ids}"
    version = "0.0.1"
    cluster_name = "flyte-cluster"
    spot_instances = true
    vpc_id = "${module.base.vpc_id}"
    env_name = "flyte-ap-south-1"
    ami_type = "AL2_x86_64"
    node_instance_type = "t3.medium"
    GPU = 
  }
