#!/bin/bash

# Define your node IPs and hostnames
MASTER="csdis-master-node-001@10.0.0.191"
WORKERS=("csdis-cluster-node-001@10.0.0.17" "csdis-cluster-node-002@10.0.0.127")

# Common setup on all nodes
setup_node() {
  ssh "$1" "sudo swapoff -a && sudo sed -i '/ swap / s/^/#/' /etc/fstab"
  ssh "$1" <<EOF
sudo apt-get update && sudo apt upgrade -y
sudo apt-get install -y apt-transport-https curl containerd
sudo mkdir -p /etc/containerd
containerd config default | sudo tee /etc/containerd/config.toml
sudo systemctl restart containerd
sudo systemctl enable containerd

sudo curl -fsSL https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
sudo apt-add-repository "deb http://apt.kubernetes.io/ kubernetes-xenial main"
sudo apt-get update
sudo apt-get install -y kubelet kubeadm kubectl
sudo apt-mark hold kubelet kubeadm kubectl
EOF
}

echo "[*] Setting up master node ($MASTER)"
setup_node "$MASTER"

for node in "${WORKERS[@]}"; do
  echo "[*] Setting up worker node ($node)"
  setup_node "$node"
done

# Initialize Kubernetes on master
echo "[*] Initializing master"
ssh "$MASTER" <<EOF
sudo kubeadm init 

mkdir -p \$HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf \$HOME/.kube/config
sudo chown \$(id -u):\$(id -g) \$HOME/.kube/config

# Install Cilium CNI
kubectl create -f https://raw.githubusercontent.com/cilium/cilium/v1.15.4/install/kubernetes/quick-install.yaml
kubectl -n kube-system wait --for=condition=Ready pod -l k8s-app=cilium --timeout=180s
EOF

# Fetch join command
JOIN_CMD=$(ssh "$MASTER" "kubeadm token create --print-join-command")

# Join workers
for node in "${WORKERS[@]}"; do
  echo "[*] Joining worker node ($node)"
  ssh "$node" "sudo $JOIN_CMD"
done

echo "[✔] Kubernetes cluster setup complete!"
