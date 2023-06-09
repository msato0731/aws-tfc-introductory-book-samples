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

# resource "aws_instance" "main" {
#   ami                    = "ami-0c55b159cbfafe1f0"
#   instance_type          = "t2.micro"
#   vpc_security_group_ids = [aws_security_group.web.id]
#   subnet_id              = aws_subnet.web.id
#   tags = {
#     Name = "web"
#   }
# }
