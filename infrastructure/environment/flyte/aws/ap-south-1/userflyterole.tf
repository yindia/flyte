
  module "userflyterole"  {
    layer_name = "flyte-ap-south-1"
    source = "tqindia/cops/cloud/module/aws_iam_role"
    links = [
      {
        s3 = [
          "write"
        ]
      }
    ]
    env_name = "flyte-ap-south-1"
    extra_iam_policies = [
      "arn:aws:iam::aws:policy/CloudWatchEventsFullAccess"
    ]
    kubernetes_trusts = [
      {
        open_id_url = "${module.k8scluster.k8s_openid_provider_url}"
        open_id_arn = "${module.k8scluster.k8s_openid_provider_arn}"
        service_name = "*"
        namespace = "*"
      }
    ]
    version = "0.0.1"
    allowed_k8s_services = [
      {
        namespace = "*"
        service_name = "*"
      }
    ]
    allowed_iams = [
      
    ]
  }
