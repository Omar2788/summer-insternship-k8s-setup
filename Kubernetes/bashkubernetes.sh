#!/bin/bash

set -e

if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <master-node-ip>"
    exit 1
fi

MASTER_NODE_IP=$1

# Install containerd
echo "================================================================="
echo "Installing containerd"
echo "================================================================="
sudo apt update
sudo apt install containerd -y
sudo systemctl enable containerd
sudo systemctl status containerd

# Configure containerd
echo "================================================================="
echo "Configuring containerd"
echo "================================================================="
sudo mkdir -p /etc/containerd
sudo containerd config default | sudo tee /etc/containerd/config.toml
sudo sed -i 's/SystemdCgroup = false/SystemdCgroup = true/' /etc/containerd/config.toml
sudo systemctl restart containerd

# Install Kubernetes tools
echo "================================================================="
echo "Installing Kubernetes tools"
echo "================================================================="
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.30/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.30/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list
sudo apt update
sudo apt install kubeadm kubelet kubectl -y
sudo apt-mark hold kubeadm kubelet kubectl

# Prepare the node for Kubernetes
echo "================================================================="
echo "Preparing node for Kubernetes"
echo "================================================================="
sudo swapoff -a
sudo sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab

sudo tee /etc/modules-load.d/containerd.conf <<EOF
overlay
br_netfilter
EOF

sudo modprobe overlay
sudo modprobe br_netfilter

sudo tee /etc/sysctl.d/kubernetes.conf <<EOF
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
net.ipv4.ip_forward = 1
EOF

sudo sysctl --system

# Set hostname and update hosts file
echo "================================================================="
echo "Setting hostname and updating hosts file"
echo "================================================================="
sudo hostnamectl set-hostname master-node
echo "$MASTER_NODE_IP master-node" | sudo tee -a /etc/hosts

# Configure kubelet
echo "================================================================="
echo "Configuring kubelet"
echo "================================================================="
sudo tee /etc/default/kubelet <<EOF
KUBELET_EXTRA_ARGS="--cgroup-driver=systemd"
EOF
sudo systemctl daemon-reload
sudo systemctl restart kubelet

# Initialize Kubernetes on master node
echo "================================================================="
echo "Initializing Kubernetes on master node"
echo "================================================================="
sudo kubeadm init --control-plane-endpoint=master-node --upload-certs --cri-socket=unix:///var/run/containerd/containerd.sock
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

echo "================================================================="
echo "Kubernetes initialization complete."
echo "Please save the kubeadm join command for worker nodes."
echo "================================================================="
