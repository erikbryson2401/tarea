output "guestbook_node_port" {
  description = "NodePort for guestbook frontend"
  value       = module.guestbook.guestbook_node_port
}

output "grafana_node_port" {
  description = "NodePort for Grafana"
  value       = module.logging.grafana_node_port
}

output "kibana_node_port" {
  description = "NodePort for Kibana"
  value       = module.logging.kibana_node_port
}
