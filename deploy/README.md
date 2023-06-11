how I created the template: https://vectops.com/2020/05/provision-proxmox-vms-with-terraform-quick-and-easy/


After creating the template on pve1, I cloned the template into a new VMs and then migrated the new VMs to pve2 and pve3 and converted them to templates there.


About the module: https://medium.com/geekculture/deploy-a-virtual-machine-to-proxmox-with-terraform-733301842f1a

Inspiration and serveral lines of code shamelessly stolen from: https://github.com/loeken/homelab/tree/main/deploy/terraform/k3s-proxmox

