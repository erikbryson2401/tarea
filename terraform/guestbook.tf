# Redis Master
resource "kubernetes_deployment" "redis_master" {
  metadata {
    name      = "redis-master"
    namespace = "default"
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
          image = "redis:7"
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
    namespace = "default"
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

# Guestbook Frontend
resource "kubernetes_deployment" "guestbook" {
  metadata {
    name      = "guestbook"
    namespace = "default"
    labels = {
      app = "guestbook"
    }
  }
  spec {
    replicas = 2
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
          image = "paulczar/gb-frontend:v5"
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
    namespace = "default"
  }
  spec {
    type = "NodePort"
    selector = {
      app = "guestbook"
    }
    port {
      port        = 80
      target_port = 80
      node_port   = 30080
    }
  }
}
