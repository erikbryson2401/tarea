# Elasticsearch
resource "kubernetes_deployment" "elasticsearch" {
  metadata {
    name      = "elasticsearch"
    namespace = kubernetes_namespace.logging.metadata[0].name
  }
  spec {
    replicas = 1
    selector {
      match_labels = {
        app = "elasticsearch"
      }
    }
    template {
      metadata {
        labels = {
          app = "elasticsearch"
        }
      }
      spec {
        container {
          name  = "elasticsearch"
          image = "docker.elastic.co/elasticsearch/elasticsearch:8.12.0"
          env {
            name  = "discovery.type"
            value = "single-node"
          }
          env {
            name  = "xpack.security.enabled"
            value = "false"
          }
          env {
            name  = "ES_JAVA_OPTS"
            value = "-Xms512m -Xmx512m"
          }
          port {
            container_port = 9200
          }
          resources {
            limits = {
              memory = "1Gi"
              cpu    = "1000m"
            }
            requests = {
              memory = "512Mi"
              cpu    = "500m"
            }
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "elasticsearch" {
  metadata {
    name      = "elasticsearch"
    namespace = kubernetes_namespace.logging.metadata[0].name
  }
  spec {
    selector = {
      app = "elasticsearch"
    }
    port {
      port        = 9200
      target_port = 9200
    }
  }
}

# Kibana
resource "kubernetes_deployment" "kibana" {
  metadata {
    name      = "kibana"
    namespace = kubernetes_namespace.logging.metadata[0].name
  }
  spec {
    replicas = 1
    selector {
      match_labels = {
        app = "kibana"
      }
    }
    template {
      metadata {
        labels = {
          app = "kibana"
        }
      }
      spec {
        container {
          name  = "kibana"
          image = "docker.elastic.co/kibana/kibana:8.12.0"
          env {
            name  = "ELASTICSEARCH_HOSTS"
            value = "http://elasticsearch:9200"
          }
          port {
            container_port = 5601
          }
          resources {
            limits = {
              memory = "1Gi"
              cpu    = "1000m"
            }
            requests = {
              memory = "512Mi"
              cpu    = "500m"
            }
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "kibana" {
  metadata {
    name      = "kibana"
    namespace = kubernetes_namespace.logging.metadata[0].name
  }
  spec {
    type = "NodePort"
    selector = {
      app = "kibana"
    }
    port {
      port        = 5601
      target_port = 5601
      node_port   = 30601
    }
  }
}

# Grafana
resource "kubernetes_deployment" "grafana" {
  metadata {
    name      = "grafana"
    namespace = kubernetes_namespace.logging.metadata[0].name
  }
  spec {
    replicas = 1
    selector {
      match_labels = {
        app = "grafana"
      }
    }
    template {
      metadata {
        labels = {
          app = "grafana"
        }
      }
      spec {
        container {
          name  = "grafana"
          image = "grafana/grafana:10.3.0"
          env {
            name  = "GF_SECURITY_ADMIN_PASSWORD"
            value = "admin"
          }
          port {
            container_port = 3000
          }
          resources {
            limits = {
              memory = "512Mi"
              cpu    = "500m"
            }
            requests = {
              memory = "256Mi"
              cpu    = "250m"
            }
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "grafana" {
  metadata {
    name      = "grafana"
    namespace = kubernetes_namespace.logging.metadata[0].name
  }
  spec {
    type = "NodePort"
    selector = {
      app = "grafana"
    }
    port {
      port        = 3000
      target_port = 3000
      node_port   = 30300
    }
  }
}
