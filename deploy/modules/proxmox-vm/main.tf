resource "proxmox_vm_qemu" "virtual_machines" {
  for_each         = { for machine in var.virtual_machines : machine.name => machine }
  name             = each.value.name
  qemu_os          = each.value.qemu_os
  desc             = each.value.description
  target_node      = each.value.target_node
  os_type          = each.value.os_type
  full_clone       = each.value.full_clone
  clone            = each.value.template
  memory           = each.value.memory
  sockets          = each.value.socket
  cores            = each.value.cores
  sshkeys          = var.ssh_keys
  ipconfig0        = "ip=${each.value.ip_address}/32,gw=${var.gateway_ip}"
  automatic_reboot = each.value.automatic_reboot
  nameserver       = join(" ", var.name_servers)

  disk {
    storage = each.value.storage_dev
    type    = each.value.disk_type
    size    = each.value.storage
  }

  network {
    bridge = each.value.network_bridge_type
    model  = each.value.network_model
    mtu    = 0
    # macaddr  = each.value.mac_address
    queues   = 0
    rate     = 0
    firewall = each.value.network_firewall
  }
  lifecycle {
    ignore_changes = [
      ciuser,
      agent,
      vcpus
    ]
  }
}

resource "null_resource" "update" {
  depends_on = [proxmox_vm_qemu.virtual_machines]
  for_each   = { for machine in var.virtual_machines : machine.name => machine }
  connection {
    type        = "ssh"
    host        = each.value.ip_address
    user        = var.ssh_username
    private_key = file(var.ssh_private_key)
  }
  provisioner "remote-exec" {
    inline = [
      "sudo apt update",
      "sudo apt upgrade -y",
      "sudo apt install qemu-guest-agent curl -y",
      "sudo systemctl enable qemu-guest-agent",
      "sudo systemctl start qemu-guest-agent"
    ]
  }
}
