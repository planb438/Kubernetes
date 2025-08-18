Backing up an etcd cluster 

--

export ETCDCTL_API=3

---

sudo etcdctl --endpoints=https://127.0.0.1:2379 \
  --cacert=/etc/kubernetes/pki/etcd/ca.crt --cert=/etc/kubernetes/pki/etcd/server.crt --key=/etc/kubernetes/pki/etcd/server.key \
  snapshot save /home/master-node-001/backUp-Cluster-kubernetes.db

---

  sudo etcdctl --write-out=table snapshot status backUp-Cluster-kubernetes.db

  ---
  
export ETCDCTL_API=3

---
etcdctl --data-dir <data-dir-location> snapshot restore snapshot.db

---

Here's how to properly restore your etcd snapshot:

Solution: Force Restore Etcd Snapshot
First, stop kube-apiserver (to prevent conflicts):

bash
sudo systemctl stop kube-apiserver
Remove the existing etcd data directory:

bash
sudo rm -rf /var/lib/etcd/default.etcd
Restore the snapshot (using your original command with --data-dir flag):

bash
sudo ETCDCTL_API=3 etcdctl --endpoints=https://127.0.0.1:2379 \
  --cacert=/etc/kubernetes/pki/etcd/ca.crt \
  --cert=/etc/kubernetes/pki/etcd/server.crt \
  --key=/etc/kubernetes/pki/etcd/server.key \
  snapshot restore /home/master-node-001/backUp-Cluster-kubernetes.db \
  --data-dir=/var/lib/etcd/restored
Update etcd service configuration (if you restored to a non-default path):

bash
sudo vim /etc/kubernetes/manifests/etcd.yaml
Change the --data-dir flag to point to your restored directory:

yaml
- --data-dir=/var/lib/etcd/restored
Restart etcd and kube-apiserver:

bash
sudo systemctl restart kubelet
sudo systemctl start kube-apiserver
Verify the restore:

bash
sudo ETCDCTL_API=3 etcdctl --endpoints=https://127.0.0.1:2379 \
  --cacert=/etc/kubernetes/pki/etcd/ca.crt \
  --cert=/etc/kubernetes/pki/etcd/server.crt \
  --key=/etc/kubernetes/pki/etcd/server.key \
  get / --prefix --keys-only
Alternative Method (If Using kubeadm)
If you're using kubeadm, you can also restore the etcd snapshot like this:

bash
sudo kubeadm etcd snapshot restore /home/master-node-001/backUp-Cluster-kubernetes.db \
  --data-dir=/var/lib/etcd/restored
Key Notes
Cluster Downtime: This process requires temporary downtime of the control plane.

Backup First: Always backup current etcd data before restoring.

Consistency: Ensure all control plane nodes are restored to the same snapshot if you have a multi-master setup.
