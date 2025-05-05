#!/bin/bash

# ──[ CONFIGURE HOSTNAME ]────────────────────────────────────────────
sudo hostnamectl set-hostname csdis-master-node-001

# ──[ OPTIONAL: Add worker hostnames to /etc/hosts ]──────────────────
echo "
10.0.0.191 csdis-master-node-001
10.0.0.17 csdis-cluster-node-001
10.0.0.127 csdis-cluster-node-002
" | sudo tee -a /etc/hosts

echo "[*] Disabling swap"
sudo swapoff -a
sudo sed -i '/ swap / s/^/#/' /etc/fstab

echo "[*] Installing containerd"
apt-get update &&  apt-get install containerd.io -y

echo "[*] Configuring containerd"
sudo mkdir -p /etc/containerd
containerd config default | tee /etc/containerd/config.toml
sed -e 's/SystemdCgroup = false/SystemdCgroup = true/g' -i /etc/containerd/config.toml
systemctl restart containerd
sudo systemctl enable containerd


echo "[*] Loading required kernel modules"
sudo modprobe overlay
sudo modprobe br_netfilter

sudo tee /etc/modules-load.d/k8s.conf <<EOF
overlay
br_netfilter
EOF

echo "[*] Applying sysctl params"
sudo tee /etc/sysctl.d/k8s.conf <<EOF
net.bridge.bridge-nf-call-iptables  = 1
net.ipv4.ip_forward                 = 1
net.bridge.bridge-nf-call-ip6tables = 1
EOF

sudo sysctl --system

sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg

echo "[*] Adding Kubernetes repo"
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.31/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
echo "deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.31/deb/ /" | sudo tee /etc/apt/sources.list.d/kubernetes.list

sudo apt-get update
sudo apt-get install -y kubeadm=1.31.1-1.1 kubelet=1.31.1-1.1 kubectl=1.31.1-1.1
sudo apt-mark hold kubelet kubeadm kubectl

echo "[*] Initializing Kubernetes master"
sudo kubeadm init --kubernetes-version=1.31.1  --pod-network-cidr=192.168.0.0/16  --node-name=cpsdis-master-node-001 --control-plane-endpoint=csdis-master-node-001
echo "[*] Setting up kubeconfig"
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

echo "[*] Please install a network plugin"
echo "[*] For example, to install Cilium:"

echo "[✔] Master node setup complete!"
echo "[*] Save this join command and run it on each worker node:"
kubeadm token create --print-join-command