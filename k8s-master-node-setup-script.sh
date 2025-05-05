#!/bin/bash

# ──[ CONFIGURE HOSTNAME ]────────────────────────────────────────────
sudo hostnamectl set-hostname csdis-master-node-001

# ──[ OPTIONAL: Add worker hostnames to /etc/hosts ]──────────────────
echo "
10.0.0.191 csdis-master-node-001
10.0.0.17 csdis-cluster-node-001
10.0.0.127 csdis-cluster-node-002
" | sudo tee -a /etc/hosts

# ──[ Disable swap (required for Kubernetes) ]────────────────────────
sudo swapoff -a
sudo sed -i '/ swap / s/^/#/' /etc/fstab

# ──[ Install dependencies ]──────────────────────────────────────────
sudo apt-get update && sudo apt-get upgrade -y
sudo apt-get install -y apt-transport-https curl containerd

# ──[ Configure containerd ]──────────────────────────────────────────
sudo mkdir -p /etc/containerd
containerd config default | sudo tee /etc/containerd/config.toml
sudo systemctl restart containerd
sudo systemctl enable containerd

# ──[ Install Kubernetes components ]─────────────────────────────────
sudo curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.29/deb/Release.key | sudo tee /etc/apt/keyrings/kubernetes-apt-keyring.asc > /dev/null
echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.asc] https://pkgs.k8s.io/core:/stable:/v1.29/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list
sudo apt-get update
sudo apt-get install -y kubelet kubeadm kubectl
sudo apt-mark hold kubelet kubeadm kubectl

# ──[ Initialize cluster ]────────────────────────────────────────────
sudo kubeadm init --node-name=csdis-master-node-001 --pod-network-cidr=192.168.0.0/16

# ──[ Configure kubeconfig ]──────────────────────────────────────────
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

# ──[ Install Cilium CNI ]────────────────────────────────────────────
kubectl create -f https://raw.githubusercontent.com/cilium/cilium/v1.15.4/install/kubernetes/quick-install.yaml
kubectl -n kube-system wait --for=condition=Ready pod -l k8s-app=cilium --timeout=180s

# ──[ Display Join Command ]──────────────────────────────────────────
echo "[✔] Master setup complete!"
kubeadm token create --print-join-command
