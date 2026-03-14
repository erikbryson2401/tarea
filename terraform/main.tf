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

resource "kubernetes_namespace" "logging" {
  metadata {
    name = var.logging_namespace
  }
}

module "guestbook" {
  source            = "./modules/guestbook"
  namespace         = var.guestbook_namespace
  frontend_replicas = var.frontend_replicas
  frontend_image    = var.frontend_image
  redis_image       = var.redis_image
  node_port         = var.guestbook_node_port
}

module "logging" {
  source                 = "./modules/logging"
  namespace              = kubernetes_namespace.logging.metadata[0].name
  elasticsearch_image    = var.elasticsearch_image
  kibana_image           = var.kibana_image
  grafana_image          = var.grafana_image
  grafana_admin_password = var.grafana_admin_password
  kibana_node_port       = var.kibana_node_port
  grafana_node_port      = var.grafana_node_port

  filebeat_image          = var.filebeat_image
  depends_on = [kubernetes_namespace.logging]
}
