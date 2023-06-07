terraform {
  cloud {
    organization = "<Organization名>" # 書き換える
    workspaces {
      name = "tfc-iam-role-test"
    }
  }
}

provider "aws" {
  region = "ap-northeast-1"
}

resource "aws_sqs_queue" "my_queue" {
  name = "my-queue"
}
