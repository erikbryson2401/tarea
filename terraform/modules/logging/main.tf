resource "kubernetes_deployment" "elasticsearch" {
  metadata {
    name      = "elasticsearch"
    namespace = var.namespace
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
          image = var.elasticsearch_image
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
          readiness_probe {
            http_get {
              path = "/_cluster/health"
              port = 9200
            }
            initial_delay_seconds = 30
            period_seconds        = 10
            failure_threshold     = 5
          }
          liveness_probe {
            http_get {
              path = "/_cluster/health"
              port = 9200
            }
            initial_delay_seconds = 60
            period_seconds        = 20
            failure_threshold     = 3
          }
          volume_mount {
            name       = "elasticsearch-storage"
            mount_path = "/usr/share/elasticsearch/data"
          }
        }
        volume {
          name = "elasticsearch-storage"
          persistent_volume_claim {
            claim_name = kubernetes_persistent_volume_claim.elasticsearch.metadata[0].name
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "elasticsearch" {
  metadata {
    name      = "elasticsearch"
    namespace = var.namespace
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

resource "kubernetes_deployment" "kibana" {
  metadata {
    name      = "kibana"
    namespace = var.namespace
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
          image = var.kibana_image
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
          readiness_probe {
            http_get {
              path = "/api/status"
              port = 5601
            }
            initial_delay_seconds = 60
            period_seconds        = 15
            failure_threshold     = 5
          }
          liveness_probe {
            http_get {
              path = "/api/status"
              port = 5601
            }
            initial_delay_seconds = 90
            period_seconds        = 30
            failure_threshold     = 3
          }
          volume_mount {
            name       = "kibana-storage"
            mount_path = "/usr/share/kibana/data"
          }
        }
        volume {
          name = "kibana-storage"
          persistent_volume_claim {
            claim_name = kubernetes_persistent_volume_claim.kibana.metadata[0].name
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "kibana" {
  metadata {
    name      = "kibana"
    namespace = var.namespace
  }
  spec {
    type = "ClusterIP"
    selector = {
      app = "kibana"
    }
    port {
      port        = 5601
      target_port = 5601
    }
  }
}

resource "kubernetes_deployment" "grafana" {
  metadata {
    name      = "grafana"
    namespace = var.namespace
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
          image = var.grafana_image
          env {
            name = "GF_SECURITY_ADMIN_PASSWORD"
            value_from {
              secret_key_ref {
                name = kubernetes_secret.grafana.metadata[0].name
                key  = "admin-password"
              }
            }
          }
          env {
            name  = "GF_PATHS_PROVISIONING"
            value = "/etc/grafana/provisioning"
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
          readiness_probe {
            http_get {
              path = "/api/health"
              port = 3000
            }
            initial_delay_seconds = 30
            period_seconds        = 10
            failure_threshold     = 3
          }
          volume_mount {
            name       = "grafana-storage"
            mount_path = "/var/lib/grafana"
          }
          volume_mount {
            name       = "grafana-datasources"
            mount_path = "/etc/grafana/provisioning/datasources"
          }
        }
        volume {
          name = "grafana-storage"
          persistent_volume_claim {
            claim_name = kubernetes_persistent_volume_claim.grafana.metadata[0].name
          }
        }
        volume {
          name = "grafana-datasources"
          config_map {
            name = kubernetes_config_map.grafana_datasource.metadata[0].name
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "grafana" {
  metadata {
    name      = "grafana"
    namespace = var.namespace
  }
  spec {
    type = "NodePort"
    selector = {
      app = "grafana"
    }
    port {
      port        = 3000
      target_port = 3000
      node_port   = var.grafana_node_port
    }
  }
}

resource "kubernetes_service_account" "filebeat" {
  metadata {
    name      = "filebeat"
    namespace = var.namespace
  }
}

resource "kubernetes_cluster_role" "filebeat" {
  metadata {
    name = "filebeat"
  }
  rule {
    api_groups = [""]
    resources  = ["namespaces", "pods", "nodes"]
    verbs      = ["get", "watch", "list"]
  }
}

resource "kubernetes_cluster_role_binding" "filebeat" {
  metadata {
    name = "filebeat"
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "filebeat"
  }
  subject {
    kind      = "ServiceAccount"
    name      = "filebeat"
    namespace = var.namespace
  }
}

resource "kubernetes_config_map" "filebeat" {
  metadata {
    name      = "filebeat-config"
    namespace = var.namespace
  }
  data = {
    "filebeat.yml" = <<-YAML
      filebeat.inputs:
      - type: container
        paths:
          - /var/log/containers/*.log
        processors:
        - add_kubernetes_metadata:
            host: $${NODE_NAME}
            matchers:
            - logs_path:
                logs_path: "/var/log/containers/"
      output.elasticsearch:
        hosts: ["http://elasticsearch:9200"]
      setup.ilm.enabled: true
      setup.ilm.rollover_alias: "filebeat"
      setup.ilm.pattern: "{now/d}-000001"
      setup.ilm.policy_name: "filebeat-policy"
      setup.template.name: "filebeat"
      setup.template.pattern: "filebeat-*"
    YAML
  }
}

resource "kubernetes_daemonset" "filebeat" {
  metadata {
    name      = "filebeat"
    namespace = var.namespace
  }
  spec {
    selector {
      match_labels = {
        app = "filebeat"
      }
    }
    template {
      metadata {
        labels = {
          app = "filebeat"
        }
      }
      spec {
        service_account_name = kubernetes_service_account.filebeat.metadata[0].name
        container {
          name  = "filebeat"
          image = var.filebeat_image
          args  = ["-c", "/etc/filebeat.yml", "-e"]
          env {
            name = "NODE_NAME"
            value_from {
              field_ref {
                field_path = "spec.nodeName"
              }
            }
          }
          resources {
            limits = {
              memory = "200Mi"
              cpu    = "200m"
            }
            requests = {
              memory = "100Mi"
              cpu    = "100m"
            }
          }
          volume_mount {
            name       = "config"
            mount_path = "/etc/filebeat.yml"
            sub_path   = "filebeat.yml"
          }
          volume_mount {
            name       = "varlog"
            mount_path = "/var/log"
          }
          volume_mount {
            name       = "varlibdockercontainers"
            mount_path = "/var/lib/docker/containers"
            read_only  = true
          }
        }
        volume {
          name = "config"
          config_map {
            name = kubernetes_config_map.filebeat.metadata[0].name
          }
        }
        volume {
          name = "varlog"
          host_path {
            path = "/var/log"
          }
        }
        volume {
          name = "varlibdockercontainers"
          host_path {
            path = "/var/lib/docker/containers"
          }
        }
      }
    }
  }
}

resource "kubernetes_persistent_volume_claim" "grafana" {
  metadata {
    name      = "grafana-pvc"
    namespace = var.namespace
  }
  spec {
    access_modes = ["ReadWriteOnce"]
    resources {
      requests = {
        storage = var.grafana_storage_size
      }
    }
  }
}

resource "kubernetes_config_map" "grafana_datasource" {
  metadata {
    name      = "grafana-datasources"
    namespace = var.namespace
  }
  data = {
    "elasticsearch.yaml" = <<-YAML
      apiVersion: 1
      datasources:
      - name: Elasticsearch
        type: elasticsearch
        access: proxy
        url: http://elasticsearch:9200
        database: "filebeat-*"
        jsonData:
          timeField: "@timestamp"
          esVersion: "8.0.0"
          logMessageField: message
          logLevelField: fields.level
        isDefault: true
    YAML
  }
}

resource "kubernetes_secret" "grafana" {
  metadata {
    name      = "grafana-secret"
    namespace = var.namespace
  }
  data = {
    admin-password = var.grafana_admin_password
  }
}

resource "kubernetes_persistent_volume_claim" "elasticsearch" {
  metadata {
    name      = "elasticsearch-pvc"
    namespace = var.namespace
  }
  spec {
    access_modes = ["ReadWriteOnce"]
    resources {
      requests = {
        storage = var.elasticsearch_storage_size
      }
    }
  }
}

resource "kubernetes_persistent_volume_claim" "kibana" {
  metadata {
    name      = "kibana-pvc"
    namespace = var.namespace
  }
  spec {
    access_modes = ["ReadWriteOnce"]
    resources {
      requests = {
        storage = var.kibana_storage_size
      }
    }
  }
}

resource "kubernetes_job" "elasticsearch_ilm_policy" {
  metadata {
    name      = "elasticsearch-ilm-setup"
    namespace = var.namespace
  }
  spec {
    template {
      metadata {}
      spec {
        restart_policy = "OnFailure"
        container {
          name  = "ilm-setup"
          image = "curlimages/curl:latest"
          command = [
            "sh", "-c",
            <<-CMD
              curl -s -X PUT "http://elasticsearch:9200/_ilm/policy/filebeat-policy" \
              -H "Content-Type: application/json" \
              -d '{
                "policy": {
                  "phases": {
                    "hot": {
                      "actions": {
                        "rollover": {
                          "max_size": "1gb",
                          "max_age": "1d"
                        }
                      }
                    },
                    "delete": {
                      "min_age": "7d",
                      "actions": {
                        "delete": {}
                      }
                    }
                  }
                }
              }'
            CMD
          ]
        }
      }
    }
  }
  wait_for_completion = false
}
