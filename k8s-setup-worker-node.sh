#!/bin/bash

set -e

echo ">>> Updating packages and installing dependencies..."
apt update && apt install -y apt-transport-https ca-certificates curl gpg lsb-release gnupg

echo ">>> Loading required kernel modules..."
modprobe overlay
modprobe br_netfilter

tee /etc/modules-load.d/k8s.conf <<EOF
overlay
br_netfilter
EOF

echo ">>> Applying sysctl settings for Kubernetes networking..."
tee /etc/sysctl.d/k8s.conf <<EOF
net.bridge.bridge-nf-call-iptables  = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward                 = 1
EOF
sysctl --system

echo ">>> Installing containerd..."
apt install -y containerd

echo ">>> Configuring containerd..."
mkdir -p /etc/containerd
containerd config default | tee /etc/containerd/config.toml > /dev/null

sed -i 's/SystemdCgroup = false/SystemdCgroup = true/' /etc/containerd/config.toml

systemctl restart containerd
systemctl enable containerd

echo ">>> Adding Kubernetes apt repository..."
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.29/deb/Release.key | gpg --dearmor -o /etc/apt/trusted.gpg.d/kubernetes.gpg
echo "deb [signed-by=/etc/apt/trusted.gpg.d/kubernetes.gpg] https://pkgs.k8s.io/core:/stable:/v1.29/deb/ /" | tee /etc/apt/sources.list.d/kubernetes.list

apt update && apt install -y kubelet kubeadm kubectl
apt-mark hold kubelet kubeadm kubectl

echo ">>> Disabling swap..."
swapoff -a
sed -i '/ swap / s/^/#/' /etc/fstab

echo ">>> Joining cluster..."
kubeadm join 10.0.0.77:6443 --token 4wmsmq.50skvgqfg076trw2 --discovery-token-ca-cert-hash sha256:01456c0209d42bf41b7bab464ca9bdd8e1cbcc6e118e4a41cbfffb8916a67bd1
# Replace MASTER_IP, TOKEN, and DISCOVERY_HASH with your actual values from kubeadm init #
