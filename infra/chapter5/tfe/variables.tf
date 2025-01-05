variable "organization_name" {
  type = string
}

variable "project_name" {
  type    = string
  default = "aws-hcp-tf-introductory-book"
}

variable "variable_set_name" {
  type    = string
  default = "aws-hcp-tf-introductory-book"
}

variable "workspace_name_suffix" {
  type    = string
  default = "aws-hcp-tf-introductory-book"
}

variable "github_organization_name" {
  type = string
}

variable "aws_run_role_arn" {
  type = string
}
