/**
 * メインTerraformファイル
 * Open WebUIのためのAWSインフラストラクチャを構築します
 */

terraform {
  required_version = ">= 1.0.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.10.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = ">= 2.5.0"
    }
    tls = {
      source  = "hashicorp/tls"
      version = ">= 3.0.0"
    }
    local = {
      source  = "hashicorp/local"
      version = ">= 2.1.0"
    }
  }

  backend "s3" {
    bucket         = "open-webui-tfstate"
    key            = "terraform.tfstate"
    region         = "ap-northeast-1"
    dynamodb_table = "terraform-state-lock"
    encrypt        = true
  }
}

provider "aws" {
  region = var.region

  default_tags {
    tags = var.default_tags
  }
}

# Retrieve EKS cluster authentication information
data "aws_eks_cluster" "cluster" {
  name = module.eks.cluster_id
  depends_on = [module.eks.cluster_id]
}

data "aws_eks_cluster_auth" "cluster" {
  name = module.eks.cluster_id
  depends_on = [module.eks.cluster_id]
}

# Kubernetes provider configuration
provider "kubernetes" {
  host                   = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.cluster.token
}

# Helm provider configuration
provider "helm" {
  kubernetes {
    host                   = data.aws_eks_cluster.cluster.endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority[0].data)
    token                  = data.aws_eks_cluster_auth.cluster.token
  }
}

# VPCモジュール
module "vpc" {
  source = "./modules/vpc"

  prefix             = var.prefix
  vpc_cidr           = var.vpc_cidr
  availability_zones = var.availability_zones
  tags               = var.default_tags
}

# RDSモジュール
module "rds" {
  source = "./modules/rds"

  prefix               = var.prefix
  private_subnet_ids   = module.vpc.private_subnet_ids
  rds_security_group_id = module.vpc.rds_security_group_id
  postgres_version     = var.postgres_version
  db_instance_class    = var.db_instance_class
  allocated_storage    = var.allocated_storage
  max_allocated_storage = var.max_allocated_storage
  db_name              = var.db_name
  db_username          = var.db_username
  db_password          = var.db_password
  multi_az             = var.multi_az
  tags                 = var.default_tags

  depends_on = [module.vpc]
}

# EKSモジュール
module "eks" {
  source = "./modules/eks"

  prefix               = var.prefix
  region               = var.region
  kubernetes_version   = var.kubernetes_version
  public_subnet_ids    = module.vpc.public_subnet_ids
  private_subnet_ids   = module.vpc.private_subnet_ids
  eks_security_group_id = module.vpc.eks_security_group_id
  node_instance_types  = var.node_instance_types
  node_disk_size       = var.node_disk_size
  node_desired_size    = var.node_desired_size
  node_min_size        = var.node_min_size
  node_max_size        = var.node_max_size
  tags                 = var.default_tags

  depends_on = [module.vpc]
}
