# CKS-Walk-Thru-001

✅ What You’ve Mastered So Far

Area	Status	Notes

🔧 Kubernetes Cluster Build	✅	kubeadm-based, containerd, PSA configured

📦 Helm + App Deployment	✅	Includes liveness/readiness probes, HPA

🔐 Secrets Encryption at Rest	✅	etcd secured

🔐 TLS/Ingress HTTPS	✅	Self-signed cert, NodePort, tested

📊 Metrics Server + HPA	✅	Functional and validated

🔍 Falco Runtime Security	✅	Working, logs verified

🧱 Network Policies (Cilium)	✅	Block/allow tested via pod communication

🎫 Kyverno + Gatekeeper	✅ Installed, tested, uninstalled cleanly	

🔑 Private Registry Access	✅	Real + fake image, creds used, worked

🖋️ Cosign + Image Signing	✅	Key pair generated, image signed/verified

📜 Audit Logs & Forensics	✅	Enabled, simulated risky events, inspected logs

🟡 Optional/Polish Areas (Not Required for CKS, But Nice to Know)

---

Task	Status
Sigstore Policy Controller	Optional
Automating cosign policy enforcement via Kyverno or Gatekeeper	Optional
EFK or Loki Log Stack for deeper observability	Optional

---

🔁 Next Step
You're at the "lock it in" stage — repeat the full workflow:

Build your cluster from scratch.

Deploy a sample app.

Secure each layer (secrets, network, runtime, policy).

Troubleshoot and observe the cluster's behavior.

Test edge cases: privilege escalation, broken probes, tampered images.

💡 Time Yourself doing each major task — CKS is hands-on, time-sensitive.
