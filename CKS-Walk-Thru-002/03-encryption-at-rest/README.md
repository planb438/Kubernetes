🔐 Scenario 3: Encrypt Kubernetes Secrets at Rest (etcd)

---

📘 Real-World Context

-

By default, Kubernetes stores Secrets in plaintext inside etcd. Anyone with access to etcd can view sensitive data like credentials, tokens, and certificates. To harden your cluster, you must enable encryption at rest for Secret objects.

-

This is a frequent CKS topic, and very realistic in production.

-

🎯 Objectives
-

Create an encryption config file

-
Enable EncryptionConfiguration in the API server
-
Restart the API server to apply the change
-
Verify encryption by inspecting the etcd data directly

---

📁 Files:

cks-labs/
└── 03-encryption-at-rest/
    ├── encryption-config.yaml
    ├── patch-apiserver.sh
    ├── test-secret.yaml
    ├── verify-encryption.sh
    └── README.md

---

# 🔐 Scenario 3: Encrypt Kubernetes Secrets at Rest

---

## 🎯 Goal
Encrypt all Kubernetes Secret objects stored in etcd using AES-CBC.

-
## 📦 Steps
1. Define an `EncryptionConfiguration` YAML
2. Patch `kube-apiserver` to use it
3. Restart API server (done automatically for static pod)
4. Test by creating a secret and reading from etcd

   
-

## ✅ Verification

---
Run:
```bash
./verify-encryption.sh
You should see binary output — not plaintext secrets.

🧼 Cleanup
bash
Copy
Edit
kubectl delete secret secret-test
sudo mv /etc/kubernetes/manifests/kube-apiserver.yaml.bak /etc/kubernetes/manifests/kube-apiserver.yaml
sudo systemctl restart kubelet

