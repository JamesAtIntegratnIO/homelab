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
      second_ip_address  = "10.130.0.1"
      description = "k3s master"

      networks = [{
        network_bridge_type = "vmbr0"
      },
      {
        network_bridge_type = "vmbr1"
      }
      ]
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
      second_ip_address = "10.130.0.2"
      description = "k3s worker"

      networks = [{
        network_bridge_type = "vmbr0"
      },
      {
        network_bridge_type = "vmbr1"
      }
      ]
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
      second_ip_address = "10.130.0.3"
      description = "k3s worker"

      networks = [{
        network_bridge_type = "vmbr0"
      },
      {
        network_bridge_type = "vmbr1"
      }
      ]
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
      ip_address         = "10.130.0.1"
      k3s_master_primary = true
    },
    {
      ip_address         = "10.130.0.2"
      k3s_worker         = true
    },
    {
      ip_address         = "10.130.0.3"
      k3s_worker         = true
    }
  ]

  cluster_cidr   = "10.128.0.0/16"
  service_cidr   = "10.129.0.0/16"
  cluster_dns    = "10.129.0.53"
  cluster_domain = "cluster.arpa"

  ssh_username    = "boboysdadda"
  ssh_private_key = "~/.ssh/id_ed25519"
}

provider "helm" {
  kubernetes {
    config_path = "./kubeconfig"
  }
}

resource "helm_release" "metallb" {
  depends_on = [
    module.k3s_cluster
  ]
  name = "metallb"
  repository = "https://metallb.github.io/metallb"
  chart = "metallb"
  namespace = "metallb-system"
  create_namespace = true

}

resource "helm_release" "metallb_address_pools" {
  depends_on = [
    helm_release.metallb
  ]
  name  = "metallb-address-pools"
  chart = "helm/metallb"
  namespace = "metallb-system"

}


resource "helm_release" "nginx_ingress" {
  depends_on = [
    module.k3s_cluster,
    helm_release.metallb_address_pools
  ]
  name = "ingress-nginx"
  repository = "https://kubernetes.github.io/ingress-nginx"
  chart = "ingress-nginx"
  namespace = "ingress-nginx"
  create_namespace = true

}

resource "helm_release" "argocd" {
  depends_on = [
    module.k3s_cluster
  ]
  name             = "argocd"
  repository       = "https://argoproj.github.io/argo-helm"
  chart            = "argo-cd"
  create_namespace = true
  namespace        = "argocd"
  version          = "5.35.0"

  # values = [
  #   "${file("argocd-values.yaml")}"
  # ]
}

resource "helm_release" "argocd_ingress" {
  depends_on = [
    helm_release.argocd
  ]
  name  = "argocd-ingress"
  chart = "helm/argocd"
  namespace = "argocd"

}