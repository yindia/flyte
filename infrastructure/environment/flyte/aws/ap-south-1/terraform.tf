
  terraform "required_providers" "helm"  {
    version = "2.6.0"
    source = "hashicorp/helm"
  }
  terraform "required_providers" "backend"  {
    local  {
      path = "./tfstate/cops.tfstate"
    }
  }
  terraform "required_providers" "aws"  {
    source = "hashicorp/aws"
    version = "4.27.0"
  }
