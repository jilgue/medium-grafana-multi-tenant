terraform {
  required_providers {
    helm = {
      source  = "hashicorp/helm"
      version = "2.4.1"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.7.1"
    }
  }
}

provider "helm" {
  kubernetes {
    config_path    = "~/.kube/config"
    config_context = "kind-kind"
  }
}

provider "kubernetes" {
  config_path    = "~/.kube/config"
  config_context = "kind-kind"
}

resource "random_password" "this" {
  length           = 16
  special          = true
  override_special = "_%@"
}

resource "kubernetes_secret" "admin" {
  metadata {
    name      = "grafana-admin"
    namespace = "default"
  }

  data = {
    admin-user     = "admin"
    admin-password = random_password.this.result
  }

  type = "Opaque"
}

# https://github.com/grafana/helm-charts
resource "helm_release" "this" {
  name       = "grafana"
  repository = "https://grafana.github.io/helm-charts"
  chart      = "grafana"
  version    = "6.17.7"

  namespace = "default"

  values = [file("values.yaml")]

  depends_on = [kubernetes_secret.admin]
}

output "admin_password" {
  value = kubernetes_secret.admin.data.admin-password
  sensitive = true
}