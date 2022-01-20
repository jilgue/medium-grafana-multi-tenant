terraform {
  required_providers {
    grafana = {
      source = "grafana/grafana"
      version = "1.18.0"
    }
  }
}

data "terraform_remote_state" "grafana" {
  backend = "local"

  config = {
    path = "${path.module}/../../010-environment/010-grafana/terraform.tfstate"
  }
}

provider "grafana" {
  url  = "http://127.0.0.1:3000"
  auth = "admin:${data.terraform_remote_state.grafana.outputs.admin_password}"
  alias = "admin"
}

locals {
  client_id   = "client-1"
  client_name = "Client 1"
}

resource "random_password" "this" {
  length           = 16
  special          = true
  override_special = "_%@"
}

module "grafana_org" {
  source = "../../000-modules/grafana-org/"

  grafana_user_email             = "${local.client_id}@localhost"
  grafana_user_name              = local.client_id
  grafana_user_login             = local.client_id
  grafana_user_password          = random_password.this.result
  grafana_user_is_admin          = true
  grafana_additional_admin_users = ["admin@localhost"]

  grafana_organization_name = local.client_name

  providers = {
    grafana = grafana.admin
  }
}

output "password" {
    value = module.grafana_org.grafana_user_password
    sensitive = true
}

provider "grafana" {
  url  = "http://127.0.0.1:3000"
  auth   = "${local.client_id}:${module.grafana_org.grafana_user_password}"
  org_id = module.grafana_org.grafana_organization_id
  alias  = "config"
}

module "grafana_config" {
  source = "../../000-modules/grafana-config/"

  grafana_folder_name = local.client_name

  providers = {
    grafana = grafana.config
  }

  depends_on = [
    module.grafana_org
  ]
}
