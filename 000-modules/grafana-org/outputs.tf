output "grafana_organization_id" {
  value = grafana_organization.this.id
}

output "grafana_user_login" {
  value = grafana_user.this.login
}

output "grafana_user_password" {
  value     = grafana_user.this.password
  sensitive = true
}

