
resource "null_resource" "k3s_installation" {
  # This resource will only be executed after the K3s virtual node is up and running
  for_each = {
    for node in var.nodes : node.ip_address => node
    if node.k3s_master_primary
  }

  provisioner "local-exec" {
    command = <<EOT
      k3sup install \
      --ip ${each.value.ip_address} \
      --ssh-key ${var.ssh_private_key} \
      --user ${var.ssh_username} \
      --cluster \
      --k3s-version ${var.kubernetes_version} \
      --k3s-extra-args '
      --advertise-address=${each.value.ip_address}
      --node-ip=${each.value.ip_address}
      --cluster-cidr=${var.cluster_cidr}
      --service-cidr=${var.service_cidr}
      --cluster-dns=${var.cluster_dns}
      --cluster-domain=${var.cluster_domain}
      --disable=traefik
      --disable=servicelb'
    EOT
  }
}

resource "null_resource" "wait_for_k3s_api" {
  depends_on = [null_resource.k3s_installation]

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


resource "null_resource" "k3s_join_master" {
  for_each = {
    for node in var.nodes : node.ip_address => node
    if node.k3s_master
  }
  depends_on = [null_resource.k3s_installation, null_resource.wait_for_k3s_api]
  provisioner "local-exec" {
    command = <<-EOT
        for i in {1..3}
        do
            k3sup join \
            --server \
            --host ${each.value.ip_address} \
            --ssh-key ~/.ssh/id_ed25519 \
            --user ${var.ssh_username} \
            --server-ip ${var.nodes[0].ip_address} \
            --k3s-version ${var.kubernetes_version} \
            --k3s-extra-args '
            --advertise-address=${each.value.ip_address}
            --node-ip=${each.value.ip_address}
            --cluster-cidr=${var.cluster_cidr}
            --service-cidr=${var.service_cidr}
            --cluster-dns=${var.cluster_dns}
            --cluster-domain=${var.cluster_domain}' \
            echo "Command failed, retrying in 10 seconds..." \
            sleep 10
        done
        EOT
  }
}

resource "null_resource" "k3s_join_worker" {
  for_each = {
    for node in var.nodes : node.ip_address => node
    if node.k3s_worker
  }
  depends_on = [null_resource.k3s_installation, null_resource.wait_for_k3s_api]
  provisioner "local-exec" {
    command = <<-EOT
        k3sup join \
        --ip ${each.value.ip_address} \
        --ssh-key ~/.ssh/id_ed25519 \
        --user ${var.ssh_username} \
        --server-ip ${var.nodes[0].ip_address} \
        --k3s-version ${var.kubernetes_version} \
        --k3s-extra-args '--node-ip=${each.value.ip_address}'
        EOT
  }
}