#!/bin/bash
set -e

# Constants
K8S_VERSION="1.31.1-1.1"
K8S_POD_SUBNET="192.168.0.0/16"
NONROOT_USER="master-node-001"
K8S_HOSTNAME_ALIAS="k8scp"

echo "🔧 Updating system and installing base packages..."
apt-get update && apt-get upgrade -y
apt-get install -y apt-transport-https software-properties-common ca-certificates curl gnupg lsb-release socat vim bash-completion

echo "🧹 Disabling swap..."
swapoff -a
sed -i '/ swap / s/^/#/' /etc/fstab

echo "🛡️  Hardening kernel parameters for Kubernetes and security..."
cat <<EOF | tee /etc/sysctl.d/99-kubernetes-cri.conf
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
net.ipv4.ip_forward = 1
kernel.panic=10
kernel.panic_on_oops=1
fs.protected_hardlinks=1
fs.protected_symlinks=1
EOF
sysctl --system

echo "📦 Installing containerd..."
mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" \
    | tee /etc/apt/sources.list.d/docker.list > /dev/null

apt-get update && apt-get install -y containerd.io

echo "⚙️ Configuring containerd to use systemd as cgroup driver..."
containerd config default | tee /etc/containerd/config.toml
sed -i 's/SystemdCgroup = false/SystemdCgroup = true/' /etc/containerd/config.toml
systemctl restart containerd
systemctl enable containerd

echo "🔑 Adding Kubernetes signing key and repository..."
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.31/deb/Release.key | gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg

cat <<EOF | tee /etc/apt/sources.list.d/kubernetes.list
deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.31/deb/ /
EOF

apt-get update

echo "☸️ Installing Kubernetes components..."
apt-get install -y kubelet=${K8S_VERSION} kubeadm=${K8S_VERSION} kubectl=${K8S_VERSION}
apt-mark hold kubelet kubeadm kubectl

echo "🌐 Detecting node IP address..."
NODE_IP=$(hostname -I | awk '{print $1}')
echo "Node IP: $NODE_IP"

echo "🔗 Adding hostname alias to /etc/hosts..."
grep -q "$K8S_HOSTNAME_ALIAS" /etc/hosts || echo "$NODE_IP $K8S_HOSTNAME_ALIAS" >> /etc/hosts

echo "📝 Creating kubeadm init config file..."
cat <<EOF | tee /root/kubeadm-config.yaml
apiVersion: kubeadm.k8s.io/v1beta3
kind: ClusterConfiguration
kubernetesVersion: v1.31.1
controlPlaneEndpoint: "$K8S_HOSTNAME_ALIAS:6443"
networking:
  podSubnet: "$K8S_POD_SUBNET"
apiServer:
  extraArgs:
    "authorization-mode": Node,RBAC
    "audit-log-path": /var/log/kubernetes/apiserver-audit.log
    "audit-log-maxage": "30"
    "audit-log-maxbackup": "10"
    "audit-log-maxsize": "100"
    "enable-admission-plugins": "NamespaceLifecycle,LimitRanger,ServiceAccount,ResourceQuota,DefaultDeny,PodSecurityPolicy"
controllerManager:
  extraArgs:
    "bind-address": "0.0.0.0"
scheduler:
  extraArgs:
    "bind-address": "0.0.0.0"
EOF

echo "🚀 Initializing Kubernetes control plane..."
kubeadm init --config=/root/kubeadm-config.yaml --upload-certs --node-name=cp | tee kubeadm-init.out

echo "👤 Configuring kubectl for root and user: $NONROOT_USER"
mkdir -p /root/.kube
cp /etc/kubernetes/admin.conf /root/.kube/config
chown root:root /root/.kube/config

mkdir -p /home/$NONROOT_USER/.kube
cp /etc/kubernetes/admin.conf /home/$NONROOT_USER/.kube/config
chown $NONROOT_USER:$NONROOT_USER /home/$NONROOT_USER/.kube/config

echo "🌐 Installing Cilium CNI plugin (Networking)..."
runuser -l $NONROOT_USER -c "curl -LO https://github.com/cilium/cilium-cli/releases/latest/download/cilium-linux-amd64"
runuser -l $NONROOT_USER -c "chmod +x cilium-linux-amd64 && sudo mv cilium-linux-amd64 /usr/local/bin/cilium"
runuser -l $NONROOT_USER -c "cilium install --version v1.15"
runuser -l $NONROOT_USER -c "cilium status --wait"

echo "✅ Kubernetes master node setup complete with security hardening!"
