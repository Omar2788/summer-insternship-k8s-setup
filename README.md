# Automation of Kubernetes Cluster Setup

This project demonstrates the automation of setting up and managing a Kubernetes cluster. It was developed during my summer internship in 2024.

## Project Overview

During my internship, I worked on automating the deployment of a Kubernetes cluster, configuring Kubernetes components with **Ansible**, and automating infrastructure deployment with **Terraform**. The Kubernetes cluster was configured to use **containerd** as the container runtime, ensuring efficiency and security across the system. Additionally, I automated the process of adding worker nodes to the cluster and followed best practices for security and scalability.

## Technologies Used

- **Kubernetes**: For managing containerized applications in the cluster.
- **containerd**: An industry-standard core container runtime.
- **Terraform**: Infrastructure as Code (IaC) tool for automating infrastructure deployment.
- **Ansible**: Automation tool used to configure and manage Kubernetes components.
- **Flannel**: A simple and easy-to-configure network fabric for Kubernetes.

## Features

- Automated Kubernetes cluster setup with containerd as the CRI (Container Runtime Interface).
- Infrastructure deployment automation using Terraform.
- Configuration of Kubernetes components using Ansible.
- Integration of Flannel for networking between Kubernetes nodes.
- Automated addition of worker nodes to the cluster.

## Setup

Follow these steps to set up the project on your local machine or server:

### Prerequisites

Before starting, ensure you have the following tools installed:

- **Terraform** (for infrastructure deployment)
- **Ansible** (for Kubernetes configuration management)
- **containerd** (as the container runtime)
- **kubectl** (to interact with the Kubernetes cluster)

### 1. Initialize and apply the Terraform configuration to create your Kubernetes infrastructure.

```bash
terraform init
terraform apply
```

### 2. Configure Kubernetes with Ansible

Once the infrastructure is created, use Ansible to configure the Kubernetes cluster. Run these commands in sequence:

```bash 
ansible-playbook -i hosts.yml installk8s.yml
ansible-playbook -i hosts.yml master.yml
ansible-playbook -i hosts.yml joinworkers.yml
```
### 3. Access the Kubernetes Cluster

After the setup is complete, you can check the status of the nodes in your Kubernetes cluster using the following command:

```bash 
kubectl get nodes
```
