variable "PLAYBOOK" {
    type = string
    description = "Path to the Ansible Playbook"
}

variable "BASTION_FLOATING_IP" {
    type = string
    description = "IP used to execute the remote script"
}

variable "IP" {
    type = string
    description = "IP used to execute ansible"
}

variable "PRIVATE_SSH_KEY" {
    type = string
    description = "Private ssh key"
}

variable "ID_RSA_FILE_PATH" {
    nullable = false
    description = "Input your id_rsa private key file path in OpenSSH format."
}

# Developer settings:
locals {

SAP_DEPLOYMENT = "sap-abap-ase-aas"
SCHEMATICS_TIMEOUT = 24         #(Max 55 Minutes). It is multiplied by 5 on Schematics deployments and it is relying on the ansible-logs number.

}