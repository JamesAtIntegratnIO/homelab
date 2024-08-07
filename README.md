[![Generate Infra Manifests](https://github.com/JamesAtIntegratnIO/homelab/actions/workflows/generate-infra-manifests.yaml/badge.svg)](https://github.com/JamesAtIntegratnIO/homelab/actions/workflows/generate-infra-manifests.yaml)
[![Generate Apps Manifests](https://github.com/JamesAtIntegratnIO/homelab/actions/workflows/generate-app-manifests.yaml/badge.svg)](https://github.com/JamesAtIntegratnIO/homelab/actions/workflows/generate-app-manifests.yaml)
[![Generate Monitoring Manifests](https://github.com/JamesAtIntegratnIO/homelab/actions/workflows/generate-monitoring-manifests.yaml/badge.svg)](https://github.com/JamesAtIntegratnIO/homelab/actions/workflows/generate-monitoring-manifests.yaml)
# My Homelab Clusters
## Installation

Cluster should be running Ubuntu and have k0s deployed
`k0sctl apply -c k0s-cluster.yaml`
Cluster should have nfs-common installed

1. Install Argocd
    ```bash
    kubectl apply -k base/k8s/argocd/overlay/in-cluster
    ```     
2. Prepare 1password credentials and tokens secret.
    1. 1password-credentials.json must be base64 encoded
    
    2. After installing the core apps, create the secrets
    ```bash
    kubectl create secret generic op-credentials
    --from-literal=1password-credentials.json=$(cat 1password-credentials.json |   base64 -w 0) -n op-connect
    ```
    3. Create onepassword-token secret
    ```bash
    kubectl create secret generic onpassword-token --from-litera=token=YOUR_TOKEN -n op-connect
    ```
3. Install the core apps using ArgoCD
    ```bash
    kubectl apply -f core/applicationset.yaml
    ```
4. Install the ArgoCD manifests again to ensure custom resources are created
    ```bash
    kubectl apply -k base/k8s/argocd/overlay/in-cluster
    ```

Current issues: cert-manager crds need to exist before helm can apply even though it has the crds
