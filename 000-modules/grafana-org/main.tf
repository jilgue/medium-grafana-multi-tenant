resource "grafana_user" "this" {
  email    = var.grafana_user_email
  name     = var.grafana_user_name
  login    = var.grafana_user_login
  password = var.grafana_user_password
  is_admin = var.grafana_user_is_admin
}

resource "grafana_organization" "this" {
  name       = var.grafana_organization_name
  admin_user = grafana_user.this.id

  admins = concat(var.grafana_additional_admin_users, [grafana_user.this.email])

  depends_on = [
    grafana_user.this
  ]
}
