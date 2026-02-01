markdown
# CKS Exercise 03: Encryption at Rest (SIMULATION)

## ⚠️ IMPORTANT SAFETY WARNING:
This is a **SIMULATION** for learning. In production:
- NEVER modify kube-apiserver on running clusters directly
- Use managed Kubernetes services (EKS, GKE, AKS) with built-in encryption
- Test encryption changes in non-production environments first

## Learning Objectives:
- Understand encryption at rest concepts
- Learn how Kubernetes encrypts secrets in etcd
- Explore different encryption strategies
- Practice safe encryption implementation

## Tasks:

### Task 1: Deploy Simulation Environment
1. Sync the `encryption-simulator` application
2. Explore the deployed resources
3. Run the verification job to see outputs

### Task 2: Analyze Encryption Methods
1. Compare plaintext vs base64 vs encrypted secrets
2. Understand what "encryption at rest" actually means
3. Learn about SealedSecrets as a Git-safe alternative

### Task 3: Create Your Own SealedSecret
1. Install kubeseal locally
   ```bash
   kubeseal --fetch-cert > public-cert.pem
Create a sealed secret:

bash
kubectl create secret generic my-secret \
  --from-literal=password=supersecret \
  --dry-run=client -o yaml | \
  kubeseal --cert public-cert.pem > sealed-secret.yaml
Apply via GitOps

Task 4: Research Real Implementation
Document how EKS/GKE/AKS implement encryption

Compare KMS vs managed keys vs bring-your-own-key

Design an encryption strategy for a hypothetical company

Success Criteria:
Simulation environment deployed via GitOps

Understanding of different secret storage methods

Created a SealedSecret safely stored in Git

Research document on production encryption strategies

Production Considerations:
Key Management: Use cloud KMS (AWS KMS, GCP KMS, Azure Key Vault)

Key Rotation: Automatic key rotation policies

Audit Logging: Monitor encryption/decryption events

Disaster Recovery: Backup encryption keys securely

Compliance: Meet regulatory requirements (HIPAA, PCI, GDPR)

text

---

## 🚀 **DEPLOYMENT WORKFLOW:**

### **Safe Options (Choose One):**

**Option A: Simulation Only (Recommended)**
Deploy encryption-simulator via ArgoCD

Run verification job

Study outputs without modifying cluster

text

**Option B: SealedSecrets (Real Encryption)**
Install sealed-secrets via ArgoCD

Use kubeseal to encrypt secrets

Store encrypted secrets in Git

text

**Option C: Kind Cluster (Isolated Testing)**
Create dedicated kind cluster with encryption

Test encryption features safely

Delete cluster when done

text

---

## 🔧 **PRODUCTION RECOMMENDATIONS:**

Instead of manual encryption configuration:

1. **AWS EKS**: Enable `secretsEncryption` with AWS KMS
2. **Google GKE**: Use Customer-Managed Encryption Keys
3. **Azure AKS**: Enable Azure Disk Encryption
4. **On-prem**: Use external KMS with Kubernetes KMS provider

---

## 💡 **KEY LEARNING POINTS:**

1. **Base64 ≠ Encryption**: Base64 is encoding, not encryption
2. **SealedSecrets**: Encrypts secrets for Git storage, but still needs etcd encryption
3. **Etcd Encryption**: Protects data at rest on etcd storage
4. **KMS Integration**: Best practice for production

---

## 🎯 **NEXT STEPS:**

**For your GitOps lab, focus on:**
1. **Simulation environment** (safe learning)
2. **SealedSecrets integration** (real encryption for Git)
3. **Documentation** on production patterns

**Want me to:**  
1. **Create SealedSecrets workflow** with GitHub Actions?  
2. **Add AWS/GCP/Azure encryption guides** as reference?  
3. **Create comparison matrix** of encryption options?  
4. **Add compliance checklist** (HIPAA, PCI, GDPR)?

This approach teaches the **concepts safely** while preparing you for **real production implementation**!