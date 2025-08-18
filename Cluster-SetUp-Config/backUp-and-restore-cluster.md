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
