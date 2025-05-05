#!/bin/bash

# ──[ CONFIGURE HOSTNAME ]────────────────────────────────────────────
sudo hostnamectl set-hostname csdis-cluster-node-001  # or node-002 on second worker

# ──[ OPTIONAL: Add master + other workers to /etc/hosts ]────────────
echo "
10.0.0.191 csdis-master-node-001
10.0.0.17 csdis-cluster-node-001
10.0.0.127 csdis-cluster-node-002
" | sudo tee -a /etc/hosts

# ──[ Disable swap ]──────────────────────────────────────────────────
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
sudo curl -fsSL https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
sudo apt-add-repository "deb http://apt.kubernetes.io/ kubernetes-xenial main"
sudo apt-get update
sudo apt-get install -y kubelet kubeadm kubectl
sudo apt-mark hold kubelet kubeadm kubectl

# ──[ Manual Step Reminder ]──────────────────────────────────────────
echo "[✔] Worker setup complete!"
echo "Paste and run the kubeadm join command you copied from the master node."
