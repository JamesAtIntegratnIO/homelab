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
  for_each = { for machine in var.virtual_machines : machine.name => machine }
  connection {
    type     = "ssh"
    host     = each.value.ip_address
    user     = var.ssh_username
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

resource "null_resource" "k3s-installation" {
  # This resource will only be executed after the K3s virtual machine is up and running
  depends_on = [null_resource.update]
  for_each = { 
    for machine in var.virtual_machines : machine.name => machine
    if machine.k3s_master
  }

  provisioner "local-exec" {
    # working_dir = var.kubeconfig_location
    command = <<EOT
      k3sup install \
      --ip ${each.value.ip_address} \
      --ssh-key ${var.ssh_private_key} \
      --user ${var.ssh_username} \
      --cluster \
      --k3s-version ${var.kubernetes_version} \
      --k3s-extra-args '--disable=traefik,servicelb --node-external-ip=${var.external_ip} --advertise-address=${each.value.ip_address} --node-ip=${each.value.ip_address}' && break
    EOT
  }
}

resource "null_resource" "wait_for_k3s_api" {
    depends_on = [null_resource.k3s-installation]
    
    provisioner "local-exec" {
        command = <<-EOT
        until kubectl --kubeconfig=./kubeconfig get nodes; do
            echo "Waiting for Kubernetes API..."
            sleep 5
        done
        echo "Kubernetes API is ready."
        
        until [ "$(kubectl --kubeconfig=./kubeconfig get apiservice v1beta1.metrics.k8s.io -o jsonpath='{.status.conditions[?(@.type=="Available")].status}')" == "True" ]; do
            echo "Waiting for Metrics API..."
            sleep 5
        done
        echo "Metrics API is ready."
        EOT
    }
}