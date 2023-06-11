module "machines" {
  source = "./modules/proxmox-vm"
  virtual_machines = [
    {
      name        = "k3s-1"
      target_node = "pve1"               # Name of the Proxmox Server
      template    = "debian10-cloudinit" # Name of Template Used to Clone
      cores       = 4
      socket      = 1
      memory      = 6144
      storage     = 20 # Size of Secondary hard drive assiged as bootable
      ip_address  = "10.0.1.105"
      description = "k3s master"
    },
    {
      name        = "k3s-2"
      target_node = "pve2"               # Name of the Proxmox Server
      template    = "debian10-cloudinit" # Name of Template Used to Clone
      cores       = 4
      socket      = 1
      memory      = 6144
      storage     = 20 # Size of Secondary hard drive assiged as bootable
      ip_address  = "10.0.1.106"
      description = "k3s worker"

    },
    {
      name        = "k3s-3"
      target_node = "pve3"               # Name of the Proxmox Server
      template    = "debian10-cloudinit" # Name of Template Used to Clone
      cores       = 4
      socket      = 1
      memory      = 6144
      storage     = 20 # Size of Secondary hard drive assiged as bootable
      ip_address  = "10.0.1.107"
      description = "k3s worker"

    }
  ]
  gateway_ip = "10.0.0.1"
  name_servers = [
    "10.0.0.1",
    "192.168.16.53",
    "127.0.0.1",
  ]
  ssh_keys         = file("~/.ssh/id_ed25519.pub")
  API_TOKEN_ID     = var.API_TOKEN_ID
  API_TOKEN_SECRET = var.API_TOKEN_SECRET

  ssh_username    = "boboysdadda"
  ssh_private_key = "~/.ssh/id_ed25519"
}

module "k3s_cluster" {
  depends_on = [
    module.machines
  ]
  source = "./modules/k3s-cluster"
  nodes = [
    {
      ip_address         = "10.0.1.105"
      k3s_master_primary = true
      k3s_master         = false
      k3s_worker         = false

    },
    {
      ip_address         = "10.0.1.106"
      k3s_master_primary = false
      k3s_master         = false
      k3s_worker         = true
    },
    {
      ip_address         = "10.0.1.107"
      k3s_master_primary = false
      k3s_master         = false
      k3s_worker         = true

    }
  ]
  ssh_username    = "boboysdadda"
  ssh_private_key = "~/.ssh/id_ed25519"
}