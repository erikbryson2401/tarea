variable "namespace" {
  description = "Namespace for logging stack"
  type        = string
  default     = "logging"
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
