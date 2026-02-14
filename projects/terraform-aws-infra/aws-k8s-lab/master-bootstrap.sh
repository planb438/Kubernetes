#!/bin/bash
# Install kubeadm on master - that's it
apt-get update
apt-get install -y apt-transport-https ca-certificates curl
swapoff -a
sed -i '/swap/d' /etc/fstab
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" > /etc/apt/sources.list.d/docker.list
apt-get update
apt-get install -y containerd.io
mkdir -p /etc/containerd
containerd config default > /etc/containerd/config.toml
sed -i 's/SystemdCgroup = false/SystemdCgroup = true/' /etc/containerd/config.toml
systemctl restart containerd
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.31/deb/Release.key | gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
echo "deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.31/deb/ /" > /etc/apt/sources.list.d/kubernetes.list
apt-get update
apt-get install -y kubeadm=1.31.1-1.1 kubelet=1.31.1-1.1 kubectl=1.31.1-1.1
apt-mark hold kubelet kubeadm kubectl
cat << EOF | sudo tee /etc/sysctl.d/kubernetes.conf
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
net.ipv4.ip_forward = 1
EOF
sudo modprobe overlay
sudo modprobe br_netfilter
cat <<EOF | sudo tee /etc/modules-load.d/k8s.conf
overlay
br_netfilter
EOF
sudo sysctl --system
sudo systemctl restart kubelet
sudo kubeadm init --apiserver-advertise-address=cp --pod-network-cidr=192.168.0.0/16
echo "For Calico to work correctly, you need to pass --pod-network-cidr=192.168.0.0/16 to kubeadm init or update the calico.yml file to match your Pod network. Note that Calico works on amd64, arm64, and ppc64le only."
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
echo "Installing Calico Network"
kubectl apply -f https://docs.projectcalico.org/v3.8/manifests/calico.yaml
sudo systemctl restart kubelet
echo "Master Node Bootstrap Script - SetUP Finish"
echo "If fail # Add an local DNS alias for our cp server.  Edit the/etc/hostsfile and add the above IP address and assign a namek8scp.
# root@cp: ̃# vim /etc/hosts10.128.0.3 k8scp    #<-- Add this line10.128.0.3 cp       #<-- Add this line127.0.0.1 localhost"





