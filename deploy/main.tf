module machines {
  source = "./modules/proxmox-vm"
  virtual_machines = [
    {
      name                = "k3s-1"
      target_node         = "pve1" # Name of the Proxmox Server
      qemu_os             = "other" # Type of Operating System
      os_type             = "cloud-init" # Set to cloud-init to utilize templates
      agent               = 1           # Set to 1 to enable the QEMU Guest Agent. Note, you must run the qemu-guest-agent daemon in the guest for this to have any effect.
      full_clone          = true        # Set to true to create a full clone, or false to create a linked clone. See the docs about cloning for more info. Only applies when clone is set.
      template            = "debian10-cloudinit" # Name of Template Used to Clone
      cores               = 4
      socket              = 1
      memory              = 6144
      storage             = "20G" # Size of Secondary hard drive assiged as bootable
      ip_address          = "10.0.1.105"
      description         = "k3s master"
      disk_type           = "virtio"
      storage_dev         = "local-lvm"
      network_bridge_type = "vmbr0"
      network_model       = "virtio"
      automatic_reboot    = true
      network_firewall    = false #defaults to false
      k3s_master = true
    }
]
  gateway_ip = "10.0.0.1"
  name_servers = [
    "10.0.0.1",
    "192.168.16.53",
    "127.0.0.1",
  ]
  ssh_keys = file("~/.ssh/id_ed25519.pub")
  API_TOKEN_ID = var.API_TOKEN_ID
  API_TOKEN_SECRET = var.API_TOKEN_SECRET

  ssh_username = "boboysdadda"
  ssh_private_key = "~/.ssh/id_ed25519"
  external_ip = "10.0.1.105"
}