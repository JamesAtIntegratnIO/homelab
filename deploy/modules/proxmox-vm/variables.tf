variable "virtual_machines" {
  type = list(object({
    name                = string
    target_node         = string
    template            = string
    ip_address          = string
    qemu_os             = optional(string, "other")
    description         = optional(string, "")
    os_type             = optional(string, "cloud-init")
    agent               = optional(number, 1)
    full_clone          = optional(bool, true)
    cores               = optional(number, 1)
    socket              = optional(number, 1)
    memory              = optional(number, 2048)
    storage             = optional(number, 10)
    disk_type           = optional(string, "virtio")
    storage_dev         = optional(string, "local-lvm")
    network_bridge_type = optional(string, "vmbr0")
    network_model       = optional(string, "virtio")
    automatic_reboot    = optional(bool, true)
    network_firewall    = optional(bool, false)
  }))
  description = "Identifies the object of virtual machines."
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

variable "ssh_keys" {
  type        = string
  description = "public ssh keys allowed for ssh for the user configured by cloud-init"
}

variable "ssh_private_key" {
  type        = string
  description = "the private ssh key that will be used to connect to the host"
}

variable "name_servers" {
  type        = list(string)
  description = "list of dns servers for cloud-init"
}

variable "gateway_ip" {
  type        = string
  description = "the gateway that the hosts will connect to"
}

