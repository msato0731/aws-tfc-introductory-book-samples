provider "aws" {
  region = "ap-northeast-1"
}

data "aws_availability_zones" "available" {}

locals {
  name     = "${basename(path.cwd)}-tfc-aws-book"
  vpc_cidr = "10.0.0.0/16"
  azs      = slice(data.aws_availability_zones.available.names, 0, 3)
}

module "vpc" {
  source             = "terraform-aws-modules/vpc/aws"
  name               = local.name
  cidr               = local.vpc_cidr
  azs                = local.azs
  private_subnets    = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 8, k)]
  enable_nat_gateway = false
}

data "aws_ami" "this" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["al2023-ami-2023*"]
  }
}

resource "aws_instance" "main" {
  ami           = data.aws_ami.this.id
  instance_type = "t3.micro"
  subnet_id     = module.vpc.private_subnets[0]
  tags = {
    Name = local.name
  }
}
