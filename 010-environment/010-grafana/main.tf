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


resource "kubernetes_secret" "admin" {
  metadata {
    name      = "grafana-admin"
    namespace = "default"
  }

  data = {
    admin-user     = "admin"
    admin-password = "admin"
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
