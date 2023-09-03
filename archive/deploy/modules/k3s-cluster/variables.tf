variable "nodes" {
  type = list(object({
    ip_address         = string
    k3s_master_primary = optional(bool, false)
    k3s_master         = optional(bool, false)
    k3s_worker         = optional(bool, false)
  }))
  description = "Identifies the nodes of k3s cluster."
}

variable "ssh_username" {
  type        = string
  description = "the user in cloud-init"
}

variable "kubeconfig_location" {
  type        = string
  default     = "/tmp/"
  description = "the location of the kubeconfig, can be overwriten to be used with minikube"
}

variable "kubernetes_version" {
  type        = string
  default     = "v1.26.4+k3s1"
  description = "which version of k3s to install, usually 1 versions behind the latest"
}

variable "external_ip" {
  type        = string
  default     = "1.2.3.4"
  description = "sets the external ip address, a script to update ips and restart k3s is also uploaded to the vm"
}

variable "ssh_private_key" {
  type        = string
  description = "the private ssh key that will be used to connect to the host"
}

variable "cluster_cidr" {
  type        = string
  description = "IPv4/IPv6 network CIDRs to use for pod IPs"
  default     = "10.42.0.0/16"
}

variable "service_cidr" {
  type        = string
  description = "IPv4/IPv6 network CIDRs to use for service IPs"
  default     = "10.43.0.0/16"
}

variable "cluster_dns" {
  type        = string
  description = "IPv4 Cluster IP for coredns service. Should be in your service-cidr range"
  default     = "10.43.0.10"
}

variable "cluster_domain" {
  type        = string
  description = "Cluster Domain"
  default     = "cluster.local"
}