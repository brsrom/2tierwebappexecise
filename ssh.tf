resource "tls_private_key" "legacy_vm" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "local_sensitive_file" "legacy_vm_private_key" {
  content         = tls_private_key.legacy_vm.private_key_openssh
  filename        = "${path.module}/.ssh/${var.legacy_vm_name}.pem"
  file_permission = "0600"
}
