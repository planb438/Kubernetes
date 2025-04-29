#!/bin/bash
set -e

# ====== CONSTANTS ======
K8S_VERSION="1.31.1-1.1"
POD_SUBNET="192.168.0.0/16"
NONROOT_USER="vagrant"  # <--- your Vagrant user

# ====== UPDATE SYSTEM ======
echo "🔧 Updating system..."
apt-get update && apt-get upgrade -y

# ====== INSTALL BASE PACKAGES ======
echo "📦 Installing required packages..."
apt-get install -y apt-transport-https ca-certificates curl gnupg lsb-release software-properties-common vim socat

# ====== DISABLE SWAP ======
echo "🧹 Disabling swap..."
swapoff -a
sed -i '/ swap / s/^/#/' /etc/fstab

# ====== SYSCTL SETTINGS ======
echo "📶 Configuring sysctl for Kubernetes..."
cat <<EOF | tee /etc/sysctl.d/kubernetes.conf
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables  = 1
net.ipv4.ip_forward                  = 1
EOF
sysctl --system

# ====== INSTALL containerd ======
echo "🐳 Installing containerd..."
mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg

echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" \
  | tee /etc/apt/sources.list.d/docker.list

apt-get update
apt-get install -y containerd.io

containerd config default | tee /etc/containerd/config.toml
sed -i 's/SystemdCgroup = false/SystemdCgroup = true/' /etc/containerd/config.toml
systemctl restart containerd
systemctl enable containerd

# ====== INSTALL Kubernetes Tools ======
echo "🔑 Adding Kubernetes repo and GPG key..."
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.31/deb/Release.key | gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg

echo "deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.31/deb/ /" \
  | tee /etc/apt/sources.list.d/kubernetes.list

apt-get update
apt-get install -y kubelet=${K8S_VERSION} kubeadm=${K8S_VERSION} kubectl=${K8S_VERSION}
apt-mark hold kubelet kubeadm kubectl

# ====== DETECT NODE IP ======
echo "🌐 Detecting IP address..."
NODE_IP=$(hostname -I | awk '{print $1}')
echo "Node IP detected: $NODE_IP"

# ====== CONFIGURE /etc/hosts ======
echo "🔗 Adding /etc/hosts entry for control plane..."
if ! grep -q "k8scp" /etc/hosts; then
  echo "$NODE_IP k8scp" >> /etc/hosts
fi

# ====== CREATE kubeadm-config.yaml ======
echo "📋 Generating kubeadm config..."
cat <<EOF | tee /root/kubeadm-config.yaml
apiVersion: kubeadm.k8s.io/v1beta3
kind: ClusterConfiguration
kubernetesVersion: v1.31.1
controlPlaneEndpoint: "k8scp:6443"
networking:
  podSubnet: "$POD_SUBNET"
---
apiVersion: kubeproxy.config.k8s.io/v1alpha1
kind: KubeProxyConfiguration
mode: "iptables"
EOF

# ====== INIT CONTROL PLANE ======
echo "🚀 Initializing Kubernetes control plane..."
kubeadm init --config=/root/kubeadm-config.yaml --upload-certs --node-name=cp | tee /root/kubeadm-init.log

# ====== CONFIGURE KUBECTL ======
echo "👤 Setting up kubectl access..."
mkdir -p $HOME/.kube
cp /etc/kubernetes/admin.conf $HOME/.kube/config
chown $(id -u):$(id -g) $HOME/.kube/config

echo "👤 Setting up kubectl for NONROOT user ($NONROOT_USER)..."
runuser -l $NONROOT_USER -c "mkdir -p /home/$NONROOT_USER/.kube"
cp /etc/kubernetes/admin.conf /home/$NONROOT_USER/.kube/config
chown $NONROOT_USER:$NONROOT_USER /home/$NONROOT_USER/.kube/config

# ====== INSTALL CILIUM ======
echo "🌐 Installing Cilium CNI..."
cd /usr/local/bin
curl -L --remote-name-all https://github.com/cilium/cilium-cli/releases/latest/download/cilium-linux-amd64.tar.gz
tar xzvf cilium-linux-amd64.tar.gz
chmod +x cilium
rm -f cilium-linux-amd64.tar.gz

echo "✅ Verifying Cilium CLI install..."
cilium version

# ====== DEPLOY CILIUM INTO CLUSTER ======
echo "📦 Deploying Cilium CNI into the cluster..."
cilium install

# Wait until all nodes are Ready
echo "⏳ Waiting for nodes to be Ready..."
kubectl wait --for=condition=Ready node --all --timeout=5m

echo "✅ CONTROL PLANE INITIALIZED SUCCESSFULLY!"
