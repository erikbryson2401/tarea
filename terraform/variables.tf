variable "guestbook_namespace" {
  description = "Namespace for guestbook"
  type        = string
  default     = "default"
}

variable "logging_namespace" {
  description = "Namespace for logging stack"
  type        = string
  default     = "logging"
}

variable "frontend_replicas" {
  description = "Number of guestbook frontend replicas"
  type        = number
  default     = 2
}

variable "frontend_image" {
  description = "Guestbook frontend image"
  type        = string
  default     = "paulczar/gb-frontend:v5"
}

variable "redis_image" {
  description = "Redis image"
  type        = string
  default     = "redis:7"
}

variable "guestbook_node_port" {
  description = "NodePort for guestbook"
  type        = number
  default     = 30080
}

variable "elasticsearch_image" {
  description = "Elasticsearch image"
  type        = string
  default     = "docker.elastic.co/elasticsearch/elasticsearch:8.12.0"
}

variable "kibana_image" {
  description = "Kibana image"
  type        = string
  default     = "docker.elastic.co/kibana/kibana:8.12.0"
}

variable "grafana_image" {
  description = "Grafana image"
  type        = string
  default     = "grafana/grafana:10.3.0"
}

variable "grafana_admin_password" {
  description = "Grafana admin password"
  type        = string
  sensitive   = true
  default     = "admin"
}

variable "kibana_node_port" {
  description = "NodePort for Kibana"
  type        = number
  default     = 30601
}

variable "grafana_node_port" {
  description = "NodePort for Grafana"
  type        = number
  default     = 30300
}

variable "filebeat_image" {
  description = "Filebeat image"
  type        = string
  default     = "docker.elastic.co/beats/filebeat:8.12.0"
}

variable "grafana_storage_size" {
  description = "Grafana persistent volume size"
  type        = string
  default     = "1Gi"
}

variable "elasticsearch_storage_size" {
  description = "Elasticsearch persistent volume size"
  type        = string
  default     = "2Gi"
}

variable "kibana_storage_size" {
  description = "Kibana persistent volume size"
  type        = string
  default     = "1Gi"
}

variable "redis_storage_size" {
  description = "Redis persistent volume size"
  type        = string
  default     = "1Gi"
}
