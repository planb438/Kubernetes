Kubernetes/gitops/
├── clusters/
│   └── cks-lab/
│       ├── applications/
│       │   ├── 09-audit-logs-setup.yaml
│       │   ├── 09-audit-policy.yaml
│       │   ├── 09-audit-testing.yaml
│       │   └── 09-audit-monitoring.yaml
│       └── manifests/
│           └── 09-audit-logs/
│               ├── infrastructure/
│               │   ├── audit-namespaces.yaml
│               │   ├── audit-service-accounts.yaml
│               │   └── audit-rbac.yaml
│               ├── policies/
│               │   ├── audit-policy-basic.yaml
│               │   ├── audit-policy-detailed.yaml
│               │   ├── audit-policy-production.yaml
│               │   └── audit-policy-development.yaml
│               ├── workloads/
│               │   ├── good-workloads/
│               │   │   ├── compliant-deployment.yaml
│               │   │   ├── secure-statefulset.yaml
│               │   │   └── audit-friendly-job.yaml
│               │   ├── bad-workloads/
│               │   │   ├── noisy-deployment.yaml
│               │   │   ├── sensitive-access-pod.yaml
│               │   │   └── privilege-escalation-attempt.yaml
│               │   └── test-workloads/
│               │       ├── secret-accessor.yaml
│               │       ├── configmap-modifier.yaml
│               │       └── rbac-tester.yaml
│               ├── testing/
│               │   ├── audit-log-generator.yaml
│               │   ├── log-verification-job.yaml
│               │   ├── policy-validation.yaml
│               │   └── compliance-check.yaml
│               ├── monitoring/
│               │   ├── audit-log-forwarder.yaml
│               │   ├── log-aggregator.yaml
│               │   ├── alert-rules.yaml
│               │   └── dashboard.yaml
│               ├── tools/
│               │   ├── audit-log-analyzer.yaml
│               │   ├── log-query-tool.yaml
│               │   └── compliance-reporter.yaml
│               └── README-exercise.md
├── policies/
│   └── audit-logging/
│       ├── baseline-audit-policy.yaml
│       ├── pci-dss-audit-requirements.yaml
│       ├── hipaa-audit-requirements.yaml
│       └── soc2-audit-requirements.yaml
└── tools/
    └── audit-tools/
        ├── kube-audit-analyzer.yaml
        ├── falco-audit-integration.yaml
        └── audit-log-export.yaml

markdown
# CKS Lab 09 - Kubernetes Audit Logging

## Lab Objectives
1. Understand Kubernetes audit logging architecture
2. Configure audit policies for different compliance requirements
3. Implement audit log collection and monitoring
4. Analyze audit logs for security insights
5. Configure node-level audit settings

## Prerequisites
- Access to control plane nodes
- kubectl configured
- ArgoCD installed

## Lab Setup

### Part 1: Node-Level Configuration
```bash
# On each control plane node
chmod +x tools/audit-tools/node-audit-setup.sh
sudo ./tools/audit-tools/node-audit-setup.sh
Part 2: Deploy via GitOps
bash
# Apply all audit lab applications
kubectl apply -f clusters/cks-lab/applications/09-audit-logs-setup.yaml
kubectl apply -f clusters/cks-lab/applications/09-audit-policy.yaml
kubectl apply -f clusters/cks-lab/applications/09-audit-testing.yaml
kubectl apply -f clusters/cks-lab/applications/09-audit-monitoring.yaml

# Monitor deployment
argocd app list | grep 09-audit
Exercises
Exercise 1: Basic Audit Logging
Deploy the basic audit policy

Generate test audit events

Locate and examine audit logs on control plane

Exercise 2: Advanced Policy Configuration
Compare different audit policies (basic, detailed, production)

Modify policies to meet specific compliance requirements

Test policy changes by generating audit events

Exercise 3: Audit Log Analysis
Use the audit log analyzer tool

Identify suspicious activities in audit logs

Create alerts for critical audit events

Exercise 4: Compliance Scenarios
Implement PCI-DSS audit requirements

Implement HIPAA audit requirements

Compare audit logs from different compliance configurations

Verification
bash
# Check if audit logs are being generated
ssh control-plane-node "sudo tail -n 10 /var/log/kubernetes/audit.log"

# Verify ArgoCD applications are synced
argocd app get 09-audit-logs-setup

# Run verification job
kubectl create -f clusters/cks-lab/manifests/09-audit-logs/testing/log-verification-job.yaml
Cleanup
bash
# Delete ArgoCD applications
kubectl delete -f clusters/cks-lab/applications/09-audit-*.yaml

# Clean up namespaces
kubectl delete namespace audit-system audit-test audit-monitoring

# Reset node configuration
sudo cp /etc/kubernetes/backups/kube-apiserver.yaml.backup* /etc/kubernetes/manifests/kube-apiserver.yaml
sudo systemctl restart kubelet
Learning Points
Audit logging is essential for security compliance

Different compliance frameworks have different audit requirements

Audit logs should be centralized and monitored

Proper audit policy design balances security and performance

text

## **Deployment Commands:**

```bash
# 1. First, set up audit logging on control plane nodes (MANUAL)
# SSH to each control plane node and run:
cd Kubernetes
sudo chmod +x tools/audit-tools/node-audit-setup.sh
sudo ./tools/audit-tools/node-audit-setup.sh

# 2. Commit and push the new lab structure
git add .
git commit -m "Add CKS Lab 09 - Kubernetes Audit Logging"
git push origin main

# 3. Deploy via ArgoCD
kubectl apply -f gitops/clusters/cks-lab/applications/09-audit-logs-setup.yaml
kubectl apply -f gitops/clusters/cks-lab/applications/09-audit-policy.yaml
kubectl apply -f gitops/clusters/cks-lab/applications/09-audit-testing.yaml
kubectl apply -f gitops/clusters/cks-lab/applications/09-audit-monitoring.yaml

# 4. Monitor deployment
argocd app sync 09-audit-logs-setup
argocd app sync 09-audit-policy
argocd app sync 09-audit-testing
argocd app sync 09-audit-monitoring

# 5. Verify
kubectl get all -n audit-system
kubectl get all -n audit-test
kubectl get all -n audit-monitoring
This follows your established pattern exactly, with:

Multiple ArgoCD applications for different components

Comprehensive testing and verification

Good/bad workload examples

Node-level setup scripts

Complete documentation

Compliance-focused policies

Monitoring and alerting components

