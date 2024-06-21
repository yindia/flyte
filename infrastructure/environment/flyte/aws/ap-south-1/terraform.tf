
  terraform "required_providers" "aws"  {
    source = "hashicorp/aws"
    version = "4.27.0"
  }
  terraform "required_providers" "helm"  {
    source = "hashicorp/helm"
    version = "2.6.0"
  }
  terraform "required_providers" "backend"  {
    local  {
      path = "./tfstate/cops.tfstate"
    }
  }
