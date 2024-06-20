
  provider "helm" "kubernetes"  {
    token = "${data.aws_eks_cluster_auth.k8s.token}"
    host = "https://${data.k8scluster.k8s.endpoint}"
    cluster_ca_certificate = "$(base64decode(module.k8scluster.k8s_ca_data))"
  }
  provider "aws"  {
    allowed_account_ids = [
      "609973658768"
    ]
    region = "ap-south-1"
  }
