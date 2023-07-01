# ##  To save state in s3. Update to suit your needs
# backend "s3" {
#   bucket = "create-an-s3-bucket-and-provide-name-here"
#   region = local.region
#   key    = "eks-cluster-with-new-vpc/terraform.tfstate"
# }

variable "region" {
  default     = "eu-west-1"
  description = "AWS region"
}

data "aws_availability_zones" "available" {}

locals {
  name            = "okta-auth0-jhipster-eks"
  region          = var.region
  cluster_version = "1.27"
  instance_types  = ["t2.large"] # can be multiple, comma separated

  vpc_cidr = "10.0.0.0/16"
  azs      = slice(data.aws_availability_zones.available.names, 0, 3)

  tags = {
    Blueprint  = local.name
    GitHubRepo = "github.com/aws-ia/terraform-aws-eks-blueprints"
  }
}

provider "aws" {
  region = local.region
}

# Kubernetes provider
# You should **not** schedule deployments and services in this workspace.
# This keeps workspaces modular (one for provision EKS, another for scheduling
# Kubernetes resources) as per best practices.
provider "kubernetes" {
  host                   = module.eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)

  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "aws"
    # This requires the awscli to be installed locally where Terraform is executed
    args = ["eks", "get-token", "--cluster-name", module.eks.cluster_name]
  }
}

provider "helm" {
  kubernetes {
    host                   = module.eks.cluster_endpoint
    cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)

    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      command     = "aws"
      # This requires the awscli to be installed locally where Terraform is executed
      args = ["eks", "get-token", "--cluster-name", module.eks.cluster_name]
    }
  }
}
