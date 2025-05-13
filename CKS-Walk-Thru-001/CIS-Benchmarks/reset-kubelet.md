## reset-kubelet
To reset the cluster:
```bash
kubeadm reset -f
rm -rf ~/.kube
kubeadm init --config=kubeadm-config.yaml --upload-certs --node-name=cp | tee kubeadm-init.out
sudo rm -rf sudo kubeadm reset -f && sudo rm -rf /etc/cni/net.d -y
