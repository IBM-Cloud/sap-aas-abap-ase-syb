output "HOSTNAME" {
  value		= module.vsi.HOSTNAME
}

output "PRIVATE_IP" {
  value		= "${data.ibm_is_instance.vsi.primary_network_interface[0].primary_ip[0].address}"
}

output "ATR_NAME" {
  value		= var.ATR_NAME
}
