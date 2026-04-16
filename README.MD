## Terraform Key Vault and Secrets ##

This is a repo to test using Terraform to create an SSH keypair and store said keypair in an Azure Key Vault. This keypair will then be used to connect to an Azure VM through Azure Bastion.

We will be creating the following resources:

- Virtual Network and subnets
- Bastion Host
- Linux VM
- Key Vault
- Key Vault access policy assigned to the Bastion Host's managed identity
- SSH Keypair

I don't know if it'll work, but I'm gonna see what happens.