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
    path = "${path.module}/../010-grafana/terraform.tfstate"
  }
}


provider "grafana" {
  url  = "http://127.0.0.1:3000"
  auth = "admin:${data.terraform_remote_state.grafana.outputs.admin_password}"
}

locals {
  users = {
    "client-1" = {
      name = "Client 1"
      email = "client-1@localhost"
      login = "client-1"
    }
    "client-2" = {
      name = "Client 2"
      email = "client-2@localhost"
      login = "client-2"
    }
  }
}

resource "random_password" "this" {
  for_each = local.users

  length           = 16
  special          = true
  override_special = "_%@"
}

resource "grafana_user" "this" {
  for_each = local.users

  email    = each.value.email
  name     = each.value.name
  login    = each.value.login
  password = random_password.this[each.key].result
  is_admin = false
}