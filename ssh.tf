resource "tls_private_key" "legacy_vm" {
  algorithm = "RSA"
  rsa_bits  = 4096

  lifecycle {
    prevent_destroy = true
  }
}
