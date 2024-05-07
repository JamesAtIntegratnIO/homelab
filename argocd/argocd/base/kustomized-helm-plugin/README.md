# Argo CD Kustomized Helm Plugin

## Overview

This project integrates Helm with Kustomize in Argo CD, allowing users to leverage Helm's templating capabilities combined with Kustomize's customization strengths. The setup involves a ConfigManagementPlugin (`kustomized-helm`) configured in Argo CD, which utilizes custom scripts (`init.sh` and `generate.sh`) to initialize environments and generate Kubernetes manifests from Helm charts with Kustomize overlays.

## Components

### Kustomization.yaml

Defines a Kustomize Component that packages the plugin configuration (`plugin.yaml`), initialization (`init.sh`), and generation (`generate.sh`) scripts into a ConfigMap. It also includes a patch (`plugin-sidecar-patch.yaml`) for the Argo CD repo server to integrate the plugin.

#### Key Elements:

- **ConfigMapGenerator**: Creates a ConfigMap containing the plugin and scripts, ensuring the plugin's assets are available to the Argo CD environment.
- **Patches**: Applies modifications to the Argo CD repo server deployment, ensuring the plugin is correctly integrated and utilized within the Argo CD system.

### Plugin.yaml

Specifies the `ConfigManagementPlugin` configuration for Argo CD. It defines the `init` and `generate` commands that point to the custom scripts stored in the ConfigMap.

#### Key Functions:

- **Init**: Runs `init.sh`, preparing the environment for the plugin. It sets up necessary directories and configures environment variables to isolate Helm and Kustomize caches and configurations.
- **Generate**: Executes `generate.sh`, which uses Helm to template a chart and Kustomize to apply overlays, generating the final Kubernetes manifests. It will search for multiple values files in a given directory. This allows you to easily separate your values which is helpful on incredibly large charts like kube-prometheus-stack

### Plugin-sidecar-patch.yaml

A patch for the Argo CD repo server deployment that adds a sidecar container configured to run the plugin. It mounts the necessary volumes to make the plugin configuration and scripts available inside the container.

#### Highlights:

- **Sidecar Container Configuration**: Configures the plugin's runtime environment, including mounting paths for scripts and plugin configuration.
- **Volumes and VolumeMounts**: Ensures scripts, configuration, and a secure temporary working directory are available to the plugin container.

## Scripts

### init.sh

Initializes the environment for the plugin, setting up isolated directories for Helm and Kustomize. It ensures a clean, controlled environment for each operation.

### generate.sh

Generates Kubernetes manifests by templating a Helm chart and applying Kustomize overlays. This script is the core of the plugin's functionality, bridging Helm and Kustomize within Argo CD.

## Usage

### Integrating into Argo CD

1. **Deploy the Plugin Components**: Apply the `kustomization.yaml` to your Argo CD namespace to create the plugin's ConfigMap and patch the repo server deployment.

   ```sh
   kubectl apply -k path/to/plugin/directory
   ```

2. **Configure Argo CD**: Ensure Argo CD recognizes the `kustomized-helm` plugin. This may involve editing `argocd-cm` ConfigMap to include the plugin definition, depending on your Argo CD version and setup.

### Adding to a Parent Kustomization.yaml

To use this plugin within a larger Kustomize project, include it as a component in your parent `kustomization.yaml`.

```yaml
components:
  - kustomized-helm-plugin
```

Ensure the path points to the directory containing your `kustomization.yaml` for the plugin. This setup allows you to manage the plugin alongside your other Kubernetes resources and configurations.

## Credit
A very large portion of this plugin was directly copied from **https://github.com/boedy/argo-cd-helm-kustomized-plugin** where their usage allows for environmental overlays. This is probably the best example I've found on how to leverage ConfigManagementPlugin effectively. 