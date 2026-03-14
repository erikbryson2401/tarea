resource "kubernetes_deployment" "redis_master" {
  metadata {
    name      = "redis-master"
    namespace = var.namespace
    labels = {
      app  = "redis"
      role = "master"
    }
  }
  spec {
    replicas = 1
    selector {
      match_labels = {
        app  = "redis"
        role = "master"
      }
    }
    template {
      metadata {
        labels = {
          app  = "redis"
          role = "master"
        }
      }
      spec {
        container {
          name  = "redis"
          image = var.redis_image
          port {
            container_port = 6379
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "redis_master" {
  metadata {
    name      = "redis-master"
    namespace = var.namespace
  }
  spec {
    selector = {
      app  = "redis"
      role = "master"
    }
    port {
      port        = 6379
      target_port = 6379
    }
  }
}

resource "kubernetes_deployment" "guestbook" {
  metadata {
    name      = "guestbook"
    namespace = var.namespace
    labels = {
      app = "guestbook"
    }
  }
  spec {
    replicas = var.frontend_replicas
    selector {
      match_labels = {
        app = "guestbook"
      }
    }
    template {
      metadata {
        labels = {
          app = "guestbook"
        }
      }
      spec {
        container {
          name  = "guestbook"
          image = var.frontend_image
          port {
            container_port = 80
          }
          env {
            name  = "GET_HOSTS_FROM"
            value = "env"
          }
          env {
            name  = "REDIS_MASTER_SERVICE_HOST"
            value = "redis-master"
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "guestbook" {
  metadata {
    name      = "guestbook"
    namespace = var.namespace
  }
  spec {
    type = "NodePort"
    selector = {
      app = "guestbook"
    }
    port {
      port        = 80
      target_port = 80
      node_port   = var.node_port
    }
  }
}
