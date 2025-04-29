#!/bin/bash
set -e

# Constants
K8S_VERSION="1.31.1-1.1"
TARBALL_URL="https://cm.lf.training/LFS258/LFS258_V2025-03-06_SOLUTIONS.tar.xz"
TARBALL_NAME="LFS258_V2025-03-06_SOLUTIONS.tar.xz"
K8S_HOSTNAME_ALIAS="k8scp"
DOWNLOAD_USER="LFtraining"
DOWNLOAD_PASS="Penguin2014"
K8S_POD_SUBNET="192.168.0.0/16"
NONROOT_USER="master-node-001"

echo "🔧 Updating system..."
apt-get update && apt-get upgrade -y

echo "📦 Installing required packages..."
apt install -y apt-transport-https software-properties-common ca-certificates socat curl gnupg lsb-release vim

echo "🧹 Disabling swap..."
swapoff -a

echo "📦 Loading kernel modules..."
modprobe overlay
modprobe br_netfilter

echo "📶 Configuring sysctl for Kubernetes..."
cat <<EOF | tee /etc/sysctl.d/kubernetes.conf
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
net.ipv4.ip_forward = 1
EOF
sysctl --system

echo "🐳 Installing containerd..."
mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" \
    | tee /etc/apt/sources.list.d/docker.list > /dev/null
apt-get update && apt-get install -y containerd.io

containerd config default | tee /etc/containerd/config.toml
sed -i 's/SystemdCgroup = false/SystemdCgroup = true/' /etc/containerd/config.toml
systemctl restart containerd

echo "🔑 Adding Kubernetes GPG key..."
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.31/deb/Release.key | gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg

echo "📦 Adding Kubernetes APT repo..."
echo "deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.31/deb/ /" \
    | tee /etc/apt/sources.list.d/kubernetes.list

apt-get update

echo "☸️ Installing Kubernetes components version $K8S_VERSION..."
apt-get install -y kubeadm=${K8S_VERSION} kubelet=${K8S_VERSION} kubectl=${K8S_VERSION}
apt-mark hold kubelet kubeadm kubectl

echo "🌐 Detecting IP address..."
NODE_IP=$(hostname -i | awk '{print $1}')
echo "Node IP detected: $NODE_IP"

echo "🔗 Adding /etc/hosts entry for k8scp..."
if ! grep -q "$K8S_HOSTNAME_ALIAS" /etc/hosts; then
    echo "$NODE_IP $K8S_HOSTNAME_ALIAS" >> /etc/hosts
fi

echo "📁 Downloading and extracting course files..."
wget --user="$DOWNLOAD_USER" --password="$DOWNLOAD_PASS" "$TARBALL_URL"
tar -xvf "$TARBALL_NAME"

echo "📋 Copying kubeadm config..."
cp ./LFS258/SOLUTIONS/s_03/kubeadm-config.yaml /root/

echo "📝 Modifying kubeadm config..."
sed -i "s|controlPlaneEndpoint:.*|controlPlaneEndpoint: \"$K8S_HOSTNAME_ALIAS:6443\"|" /root/kubeadm-config.yaml
sed -i "s|podSubnet:.*|  podSubnet: $K8S_POD_SUBNET|" /root/kubeadm-config.yaml
sed -i "s|kubernetesVersion:.*|kubernetesVersion: $K8S_VERSION|" /root/kubeadm-config.yaml
echo "🚀 Initializing Kubernetes control plane..."
kubeadm init --config=/root/kubeadm-config.yaml --upload-certs --node-name=cp | tee kubeadm-init.out

echo "👤 Configuring kubectl for root user..."
mkdir -p $HOME/.kube
cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
chown $(id -u):$(id -g) $HOME/.kube/config

echo "👤 Configuring kubectl for user: $NONROOT_USER"
runuser -l $NONROOT_USER -c "mkdir -p /home/$NONROOT_USER/.kube"
cp -i /etc/kubernetes/admin.conf /home/$NONROOT_USER/.kube/config
chown $NONROOT_USER:$NONROOT_USER /home/$NONROOT_USER/.kube/config

echo "🌐 Installing Cilium CNI plugin..."
runuser -l $NONROOT_USER -c "curl -LO https://github.com/cilium/cilium-cli/releases/latest/download/cilium-linux-amd64"
runuser -l $NONROOT_USER -c "chmod +x cilium-linux-amd64 && sudo mv cilium-linux-amd64 /usr/local/bin/cilium"

runuser -l $NONROOT_USER -c "cilium install"
runuser -l $NONROOT_USER -c "cilium status --wait"

echo "✅ Kubernetes setup with Cilium and kubectl access is complete!"
