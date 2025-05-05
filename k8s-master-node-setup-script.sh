#!/bin/bash

# Define your node IPs and hostnames
MASTER_IP="10.0.0.191"
WORKER_IPS=("10.0.0.17" "10.0.0.127")
USERNAME="ubuntu"  # change if different

# Common setup on all nodes
setup_node() {
  ssh "$USERNAME@$1" "sudo swapoff -a && sudo sed -i '/ swap / s/^/#/' /etc/fstab"
  ssh "$USERNAME@$1" <<EOF
sudo apt-get update
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

echo "[*] Setting up master node ($MASTER_IP)"
setup_node "$MASTER_IP"

for ip in "${WORKER_IPS[@]}"; do
  echo "[*] Setting up worker node ($ip)"
  setup_node "$ip"
done

# Initialize Kubernetes on master
echo "[*] Initializing master"
ssh "$USERNAME@$MASTER_IP" <<EOF
sudo kubeadm init 

mkdir -p \$HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf \$HOME/.kube/config
sudo chown \$(id -u):\$(id -g) \$HOME/.kube/config

# Install Cilium CNI
kubectl create -f https://raw.githubusercontent.com/cilium/cilium/v1.15.4/install/kubernetes/quick-install.yaml
EOF

# Fetch join command
JOIN_CMD=$(ssh "$USERNAME@$MASTER_IP" "kubeadm token create --print-join-command")

# Join workers
for ip in "${WORKER_IPS[@]}"; do
  echo "[*] Joining worker node ($ip)"
  ssh "$USERNAME@$ip" "sudo $JOIN_CMD"
done

echo "[✔] Kubernetes cluster setup complete!"
