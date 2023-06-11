variable "virtual_machines" {
  type = list(object({
    name                = string
    qemu_os             = string
    description         = string
    target_node         = string
    os_type             = string
    agent               = number
    full_clone          = bool
    template            = string
    cores               = number
    socket              = number
    memory              = number
    storage             = string
    ip_address          = string
    disk_type           = string
    storage_dev         = string
    network_bridge_type = string
    network_model       = string
    automatic_reboot    = bool
    network_firewall    = bool
  }))
  description = "Identifies the object of virtual machines."
  default = [
    {
      name                = "i should have changed this"
      ip_address          = "127.0.0.1"
      target_node         = "set_me"
      template            = "set_me"
      qemu_os             = "other"
      os_type             = "cloud-init"
      agent               = 1
      full_clone          = true
      cores               = 1
      socket              = 1
      memory              = 2048
      storage             = "20G"
      description         = ""
      disk_type           = "virtio"
      storage_dev         = "local-lvm"
      network_bridge_type = "vmbr0"
      network_model       = "virtio"
      automatic_reboot    = true
      network_firewall    = false
    }
  ]
}

variable "API_TOKEN_ID" {
  type        = string
  description = "the id of the proxmox api key"
}

variable "API_TOKEN_SECRET" {
  type        = string
  description = "the secret of the proxmox api key"
}

variable "ssh_username" {
  type        = string
  description = "the user in cloud-init"
}

variable "name_servers" {
  type        = list(string)
  description = "list of dns servers for cloud-init"
}

variable "ssh_keys" {
  type        = string
  description = "public ssh keys allowed for ssh for the user configured by cloud-init"
}

variable "ssh_private_key" {
  type        = string
  description = "the private ssh key that will be used to connect to the host"
}
variable "gateway_ip" {
  type        = string
  description = "the gateway that the hosts will connect to"
}

