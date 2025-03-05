terraform {
  required_version = "=> 1.10.2"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.82.2"
    }
  }
  cloud {
    organization = "<Organization名>" # 書き換える
    workspaces {
      name = "hcp-tf-iam-role-test"
    }
  }
}

provider "aws" {
  region = "ap-northeast-1"
}

resource "aws_sqs_queue" "my_queue" {
  name = "my-queue"
}
