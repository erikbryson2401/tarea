variable "namespace" {
  description = "Namespace to deploy guestbook"
  type        = string
  default     = "default"
}

variable "frontend_replicas" {
  description = "Number of frontend replicas"
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

variable "node_port" {
  description = "NodePort for guestbook service"
  type        = number
  default     = 30080
}
