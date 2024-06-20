
  module "adminflyterole"  {
    extra_iam_policies = [
      "arn:aws:iam::aws:policy/CloudWatchEventsFullAccess"
    ]
    links = [
      {
        s3 = [
          "write"
        ]
      },
      "topic",
      "schedulesQueue",
      "notifcationsQueue"
    ]
    env_name = "flyte-ap-south-1"
    layer_name = "flyte-ap-south-1"
    version = "0.0.1"
    allowed_k8s_services = [
      {
        namespace = "*"
        service_name = "*"
      }
    ]
    allowed_iams = [
      
    ]
    kubernetes_trusts = [
      {
        open_id_url = "${module.k8scluster.k8s_openid_provider_url}"
        open_id_arn = "${module.k8scluster.k8s_openid_provider_arn}"
        service_name = "*"
        namespace = "*"
      }
    ]
    source = "tqindia/cops/cloud/module/aws_iam_role"
  }
