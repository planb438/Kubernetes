# 🛡️ CKS Preparation Labs

Welcome to my personal lab environment for preparing for the **Certified Kubernetes Security Specialist (CKS)** exam. This repository includes practical, hands-on exercises covering core security topics in Kubernetes, inspired by real-world cluster hardening and incident response practices.

---

## 📚 Topics Covered

- ✅ Helm Security Best Practices
- 🔐 Secrets Management & Encryption at Rest
- 🧪 Image Vulnerability Scanning (Trivy)
- 📦 Admission Controllers (OPA Gatekeeper, Kyverno)
- 📜 Audit Logs & Forensics
- 🕵️ Runtime Threat Detection (Falco)
- 🔒 Pod Security Standards (PSA)
- 🌐 Network Policies (Cilium)
- ⚙️ AppArmor & Seccomp Profiles
- 🔑 RBAC Hardening

---

## 🧰 Tools Used

| Tool          | Purpose                             |
|---------------|-------------------------------------|
| Helm          | Secure app deployment               |
| Trivy         | Vulnerability scanning              |
| Falco         | Runtime threat detection            |
| OPA Gatekeeper| Policy enforcement via Rego         |
| Kyverno       | YAML-native policy engine           |
| kube-bench    | CIS Benchmark auditing              |
| AppArmor      | Linux kernel-level restrictions     |
| Cilium        | Network policy enforcement          |

---

## 🚀 Getting Started

1. Set up a Kubernetes cluster (KIND, Minikube, or cloud-based).
2. Clone this repo:
   ```bash
   git clone https://github.com/<your-username>/cks-labs.git
   cd cks-labs
