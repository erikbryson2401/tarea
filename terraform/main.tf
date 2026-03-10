terraform {
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.25"
    }
  }
}

provider "kubernetes" {
  config_path    = "~/.kube/config"
  config_context = "minikube"
}

# Namespace for logging
resource "kubernetes_namespace" "logging" {
  metadata {
    name = "logging"
  }
}
