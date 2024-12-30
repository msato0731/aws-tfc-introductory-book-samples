terraform {
  required_version = "~> 1.10.2"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.82.2"
    }
  }
}

provider "aws" {
}

locals {
  hcp_tf_hostname = "app.terraform.io"
}

data "tls_certificate" "hcp_tf_certificate" {
  url = "https://${local.hcp_tf_hostname}"
}

resource "aws_iam_openid_connect_provider" "hcp_tf_provider" {
  url             = data.tls_certificate.hcp_tf_certificate.url
  client_id_list  = ["aws.workload.identity"]
  thumbprint_list = [data.tls_certificate.hcp_tf_certificate.certificates[0].sha1_fingerprint]
}

resource "aws_iam_role" "hcp_tf_role" {
  name = "hcp-tf-role"

  assume_role_policy = <<EOF
{
 "Version": "2012-10-17",
 "Statement": [
   {
     "Effect": "Allow",
     "Principal": {
       "Federated": "${aws_iam_openid_connect_provider.hcp_tf_provider.arn}"
     },
     "Action": "sts:AssumeRoleWithWebIdentity",
     "Condition": {
       "StringEquals": {
         "${local.hcp_tf_hostname}:aud": "${one(aws_iam_openid_connect_provider.hcp_tf_provider.client_id_list)}"
       },
       "StringLike": {
         "${local.hcp_tf_hostname}:sub": "organization:${var.hcp_tf_organization_name}:project:*:workspace:*:run_phase:*"
       }
     }
   }
 ]
}
EOF
}

resource "aws_iam_policy" "hcp_tf_policy" {
  name        = "hcp-tf-policy"
  description = "HCP Terraform run policy"

  policy = <<EOF
{
 "Version": "2012-10-17",
 "Statement": [
   {
     "Effect": "Allow",
     "Action": [
       "ec2:*",
       "ssm:*",
       "sqs:*"
     ],
     "Resource": "*"
   }
 ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "hcp_tf_policy_attachment" {
  role       = aws_iam_role.hcp_tf_role.name
  policy_arn = aws_iam_policy.hcp_tf_policy.arn
}
