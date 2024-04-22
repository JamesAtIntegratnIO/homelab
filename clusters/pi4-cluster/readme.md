# Pi4-Cluster

## Introduction

The Pi4-Cluster project is designed to simplify the process of setting up, managing, and deploying applications across a Raspberry Pi 4 cluster using k0s as the Kubernetes distribution and Argo CD for continuous delivery. By leveraging k0smotron, a custom implementation of k0s tailored for the Raspberry Pi 4, and Argo CD for GitOps-based deployment strategies, this project makes it easier for developers and sysadmins to maintain and scale their applications with minimal overhead.

## Table of Contents

- [Pi4-Cluster](#pi4-cluster)
  - [Introduction](#introduction)
  - [Table of Contents](#table-of-contents)
  - [Installation](#installation)
  - [Usage](#usage)
  - [Features](#features)
  - [Dependencies](#dependencies)
  - [Configuration](#configuration)
  - [Argo CD Integration](#argo-cd-integration)
  - [K0smotron Integration](#k0smotron-integration)
  - [Links for Knowledge](#links-for-knowledge)

## Installation

1. Ensure you have a cluster of Raspberry Pi 4 devices networked together running your preferred linux distro.
2. Install k0s (k0smotron variant) as your control cluster.
3. Install Argo CD on your control machine for application deployments.
4. Clone this repository to your control machine.
5. Navigate to the `ansible` directory to apply machine-specific configurations.

## Usage

To initialize your Pi4-Cluster with k0smotron and deploy applications using Argo CD:

1. Setup k0smotron on your control cluster:
   ```shell
   kubectl apply -f ../management/application.yaml
   ```
2. Apply the Kubernetes base configurations to establish the cluster:
   ```shell
   kubectl apply -f application.yaml
   ```

## Features

- Simplified Kubernetes cluster setup on Raspberry Pi 4 using k0smotron.
- Continuous application deployment and management with Argo CD.
- Customizable Ansible scripts for easy node configuration.

## Dependencies

- Kubernetes (k0s)
- Argo CD
- Ansible
- Raspberry Pi 4
- k0smotron

## Argo CD Integration

Argo CD is used for continuous delivery of applications. Set up Argo CD to watch a Git repository for changes to your Kubernetes manifests, automatically applying updates to your cluster. This enables a GitOps workflow, simplifying deployment and management.

## K0smotron Integration
k0smotron is an open-source tool designed for the efficient management of k0s Kubernetes clusters. It stands out for allowing Kubernetes control planes to be run within a management cluster, thereby enhancing the management and operational capabilities of Kubernetes clusters. With the integration of the Cluster API, k0smotron streamlines a variety of cluster operations, such as provisioning, scaling, and upgrading, making these processes more efficient and straightforward. This tool leverages Kubernetes-native methods for hosting, scaling, and lifecycle-managing containerized k0s control planes on a Kubernetes cluster, which enables users to configure and attach workers to these virtual control planes easily. k0smotron is described as a Kubernetes operator that aims to manage the lifecycle of k0s control planes within any Kubernetes distribution cluster, emphasizing the benefits of high availability and auto-healing functionalities inherent to Kubernetes   .

## Links for Knowledge
- [Cluster API Concepts](https://cluster-api.sigs.k8s.io/user/concepts.html?#concepts)
- [Kosmotron](https://docs.k0smotron.io/stable/)