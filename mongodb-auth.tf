# --- MongoDB admin credentials (root role), authentication enabled on the VM ---

resource "random_password" "mongodb_admin" {
  length           = 24
  special          = true
  override_special = "-_."
}

resource "local_sensitive_file" "mongodb_admin_credentials" {
  content = <<-EOT
    username: ${var.mongodb_admin_username}
    password: ${random_password.mongodb_admin.result}
    connect:  mongo -u ${var.mongodb_admin_username} -p '${random_password.mongodb_admin.result}' --authenticationDatabase admin
  EOT

  filename        = "${path.module}/.ssh/mongodb-admin-credentials.txt"
  file_permission = "0600"
}
