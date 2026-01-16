terraform {
  required_version = ">= 1.10.2"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

provider "tfe" {}

data "tfe_github_app_installation" "this" {
  name = var.github_organization_name
}

resource "tfe_project" "this" {
  organization = var.organization_name
  name         = var.project_name
}

resource "tfe_variable_set" "this" {
  name         = var.variable_set_name
  organization = var.organization_name
}

resource "tfe_project_variable_set" "this" {
  project_id      = tfe_project.this.id
  variable_set_id = tfe_variable_set.this.id
}

resource "tfe_variable" "aws_provider_auth" {
  key             = "TFC_AWS_PROVIDER_AUTH"
  value           = "true"
  category        = "env"
  variable_set_id = tfe_variable_set.this.id
}

resource "tfe_variable" "aws_run_role_arn" {
  key             = "TFC_AWS_RUN_ROLE_ARN"
  value           = var.aws_run_role_arn
  category        = "env"
  variable_set_id = tfe_variable_set.this.id
}

resource "tfe_workspace" "prod" {
  name                  = "prod-${var.workspace_name_suffix}"
  organization          = var.organization_name
  project_id            = tfe_project.this.id
  auto_apply            = false
  file_triggers_enabled = false
  terraform_version     = "~> 1.10.2"
  working_directory     = "infra/chapter5/aws/prod"

  vcs_repo {
    identifier                 = "${var.github_organization_name}/aws-tfc-introductory-book-samples"
    branch                     = "main"
    github_app_installation_id = data.tfe_github_app_installation.this.id
  }
}

resource "tfe_workspace" "stg" {
  name                  = "stg-${var.workspace_name_suffix}"
  organization          = var.organization_name
  project_id            = tfe_project.this.id
  auto_apply            = true
  file_triggers_enabled = false
  terraform_version     = "~> 1.10.2"
  working_directory     = "infra/chapter5/aws/stg"

  vcs_repo {
    identifier                 = "${var.github_organization_name}/aws-tfc-introductory-book-samples"
    branch                     = "main"
    github_app_installation_id = data.tfe_github_app_installation.this.id
  }
}
