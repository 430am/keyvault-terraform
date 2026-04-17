ephemeral "tls_private_key" "ssh-vm-priv" {
    algorithm = "ED25519"    
}

ephemeral "tls_public_key" "ssh-vm-pub" {
    private_key_openssh = ephemeral.tls_private_key.ssh-vm-priv.private_key_openssh
}