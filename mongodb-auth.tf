# --- MongoDB admin credentials (root role), authentication enabled on the VM ---

resource "random_password" "mongodb_admin" {
  length           = 24
  special          = true
  override_special = "-_."

  lifecycle {
    prevent_destroy = true
  }
}
