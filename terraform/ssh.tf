ephemeral "tls_private_key" "ssh-vm-priv" {
    algorithm = "ED25519"    
}

data "tls_public_key" "ssh-vm-public" {
    private_key_pem = tls_private_key.ssh-vm-priv.private_key_pem
}