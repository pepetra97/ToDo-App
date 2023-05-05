provider "aws" {
  region = "us-west-2"
}

locals {
  cluster_name = "todo-app-eks"
}

resource "aws_vpc" "this" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Terraform   = "true"
    Environment = "dev"
    Name        = local.cluster_name
  }
}

resource "aws_subnet" "private" {
  count = 2

  cidr_block = "10.0.${count.index + 1}.0/24"
  vpc_id     = aws_vpc.this.id

  tags = {
    Terraform   = "true"
    Environment = "dev"
    Name        = "${local.cluster_name}-private-${count.index + 1}"
  }
}

resource "aws_security_group" "worker_group_mgmt_one" {
  name_prefix = "worker_group_mgmt_one"
  vpc_id      = aws_vpc.this.id
}

resource "aws_security_group" "worker_group_mgmt_two" {
  name_prefix = "worker_group_mgmt_two"
  vpc_id      = aws_vpc.this.id
}

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = local.cluster_name
  cidr = aws_vpc.this.cidr_block

  azs             = ["us-west-2a", "us-west-2b"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24"]

  enable_nat_gateway = true
  single_nat_gateway = true
}

module "eks" {
  source = "terraform-aws-modules/eks/aws"

  cluster_name = local.cluster_name
  subnets      = module.vpc.private_subnets

  tags = {
    Terraform   = "true"
    Environment = "dev"
  }

  vpc_id = aws_vpc.this.id

  node_groups_defaults = {
    additional_tags = {
      Terraform   = "true"
      Environment = "dev"
    }
  }

  node_groups = {
    example = {
      desired_capacity = 1
      max_capacity     = 1
      min_capacity     = 1

      additional_tags = {
        ExtraTag = "example"
      }
    }
  }
}
