Kubernetes/gitops/
├── clusters/
│   └── cks-lab/
│       ├── applications/
│       │   ├── 13-sa-abuse-setup.yaml
│       │   ├── 13-sa-policies.yaml
│       │   ├── 13-sa-testing.yaml
│       │   └── 13-sa-monitoring.yaml
│       └── manifests/
│           └── 13-sa-abuse-prevention/
│               ├── infrastructure/
│               │   ├── sa-namespaces.yaml
│               │   ├── sa-service-accounts.yaml
│               │   └── sa-rbac.yaml
│               ├── policies/
│               │   ├── service-account-policies.yaml
│               │   ├── token-mount-policies.yaml
│               │   ├── rbac-restriction-policies.yaml
│               │   ├── pod-security-policies.yaml
│               │   └── compliance-policies.yaml
│               ├── workloads/
│               │   ├── good-workloads/
│               │   │   ├── restricted-sa-pod.yaml
│               │   │   ├── no-token-mount.yaml
│               │   │   ├── minimal-rbac-pod.yaml
│               │   │   └── hardened-deployment.yaml
│               │   ├── bad-workloads/
│               │   │   ├── exploitable-pod.yaml
│               │   │   ├── overprivileged-sa.yaml
│               │   │   ├── token-exposure-pod.yaml
│               │   │   └── privilege-escalation.yaml
│               │   └── test-workloads/
│               │       ├── sa-abuse-test.yaml
│               │       ├── token-check-job.yaml
│               │       └── rbac-validation.yaml
│               ├── attack-scenarios/
│               │   ├── token-theft-scenario.yaml
│               │   ├── privilege-escalation-scenario.yaml
│               │   ├── lateral-movement-scenario.yaml
│               │   └── defense-evasion-scenario.yaml
│               ├── defenses/
│               │   ├── admission-controller.yaml
│               │   ├── network-policies.yaml
│               │   ├── audit-logging.yaml
│               │   └── monitoring-alerts.yaml
│               ├── tools/
│               │   ├── sa-analyzer.yaml
│               │   ├── token-scanner.yaml
│               │   ├── rbac-auditor.yaml
│               │   └── privilege-checker.yaml
│               ├── testing/
│               │   ├── sa-abuse-tests.yaml
│               │   ├── token-exposure-tests.yaml
│               │   ├── rbac-escalation-tests.yaml
│               │   └── defense-validation.yaml
│               ├── monitoring/
│               │   ├── sa-activity-monitor.yaml
│               │   ├── token-usage-dashboard.yaml
│               │   ├── rbac-violation-alerts.yaml
│               │   └── compliance-reports.yaml
│               └── README-exercise.md
├── policies/
│   └── service-account-security/
│       ├── cis-service-account.yaml
│       ├── nist-iam-policies.yaml
│       ├── pci-dss-sa-requirements.yaml
│       └── zero-trust-sa.yaml
└── tools/
    └── sa-security-tools/
        ├── sa-hardening.yaml
        ├── token-rotation.yaml
        └── rbac-cleanup.yaml


markdown
# CKS Lab 13 - Service Account Abuse Prevention

## Lab Objectives
1. Understand Kubernetes service account security risks
2. Implement best practices for service account token management
3. Prevent token theft and privilege escalation attacks
4. Configure RBAC with principle of least privilege
5. Implement admission control for service account security
6. Monitor and audit service account usage
7. Understand compliance requirements for identity and access management

## Prerequisites
- Kubernetes cluster
- kubectl configured
- ArgoCD installed
- Access to create namespaces and RBAC resources

## Lab Setup

### Part 1: Deploy via GitOps
```bash
# Apply all service account security applications
kubectl apply -f clusters/cks-lab/applications/13-sa-abuse-setup.yaml
kubectl apply -f clusters/cks-lab/applications/13-sa-policies.yaml
kubectl apply -f clusters/cks-lab/applications/13-sa-testing.yaml
kubectl apply -f clusters/cks-lab/applications/13-sa-monitoring.yaml

# Monitor deployment
argocd app list | grep 13-sa
Part 2: Verify Installation
bash
# Check security system pods
kubectl get pods -n sa-security-system

# Check test namespace
kubectl get all -n sa-security-test

# Check policies
kubectl get clusterpolicies | grep sa
Exercises
Exercise 1: Service Account Token Management
Disable automatic token mounting for default service accounts

Create dedicated service accounts for workloads

Implement token expiration and rotation

Test token theft scenarios and defenses

Exercise 2: RBAC with Least Privilege
Create minimal role definitions for specific workloads

Implement namespace segregation for service accounts

Audit existing RBAC bindings for overprivileged accounts

Test privilege escalation scenarios

Exercise 3: Admission Control Implementation
Deploy webhook for service account validation

Create policies to block insecure configurations

Test admission control with various pod specifications

Implement exception handling for special cases

Exercise 4: Monitoring and Auditing
Set up monitoring for service account token usage

Create alerts for suspicious activity

Implement audit logging for RBAC changes

Generate compliance reports for service account security

Exercise 5: Attack and Defense Scenarios
Simulate token theft and lateral movement

Test privilege escalation techniques

Implement defense mechanisms for each attack vector

Validate defense effectiveness

Hands-on Activities
Activity 1: Create Secure Service Account Configuration
bash
# Create namespace with security labels
kubectl create namespace secure-app
kubectl label namespace secure-app sa-security-enabled=true

# Create secure service account
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: ServiceAccount
metadata:
  name: app-sa
  namespace: secure-app
automountServiceAccountToken: false
EOF

# Create minimal role
cat <<EOF | kubectl apply -f -
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: app-role
  namespace: secure-app
rules:
- apiGroups: [""]
  resources: ["configmaps", "secrets"]
  verbs: ["get", "list"]
EOF

# Bind role to service account
cat <<EOF | kubectl apply -f -
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: app-binding
  namespace: secure-app
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: Role
  name: app-role
subjects:
- kind: ServiceAccount
  name: app-sa
  namespace: secure-app
EOF
Activity 2: Test Admission Control
bash
# Try to create pod with default service account (should be blocked)
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Pod
metadata:
  name: test-pod
  namespace: secure-app
spec:
  containers:
  - name: test
    image: alpine
    command: ["sleep", "3600"]
EOF

# Check admission webhook response
kubectl get events -n secure-app | grep -i "admission"

# Create compliant pod
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Pod
metadata:
  name: compliant-pod
  namespace: secure-app
spec:
  serviceAccountName: app-sa
  automountServiceAccountToken: false
  containers:
  - name: test
    image: alpine
    command: ["sleep", "3600"]
EOF
Activity 3: Audit Service Account Permissions
bash
# List all service accounts and their permissions
kubectl get serviceaccounts --all-namespaces

# Check which SAs have cluster-admin
kubectl get clusterrolebindings -o json | \
  jq -r '.items[] | select(.subjects[]?.kind=="ServiceAccount") | .metadata.name'

# Audit RBAC bindings
kubectl get rolebindings,clusterrolebindings --all-namespaces -o yaml | \
  grep -E "(ServiceAccount|ClusterRole|Role)" | \
  sort | uniq
Verification
bash
# Verify admission webhook is working
curl -k https://sa-admission-webhook.sa-security-system.svc.cluster.local:443/health

# Check security policies
kubectl get clusterpolicies | grep restrict-service-account

# Run test suite
kubectl create -f clusters/cks-lab/manifests/13-sa-abuse-prevention/testing/sa-abuse-tests.yaml

# Monitor logs
kubectl logs -n sa-security-system -l app=sa-admission-webhook --tail=20
Cleanup
bash
# Delete ArgoCD applications
kubectl delete -f clusters/cks-lab/applications/13-sa-*.yaml

# Clean up namespaces
kubectl delete namespace sa-security-system sa-security-test sa-security-monitoring

# Remove security policies
kubectl delete clusterpolicies -l cks-lab=13-sa-abuse-prevention

# Clean up test resources
kubectl delete all,sa,roles,rolebindings -n secure-app --all
Learning Points
Service accounts are a common attack vector in Kubernetes

Token mounting should be disabled by default

Principle of least privilege is essential for RBAC

Admission control can enforce security policies

Regular auditing of service account permissions is critical

Network policies can limit lateral movement using stolen tokens

Additional Resources
Kubernetes Service Accounts Documentation

RBAC Authorization

Projected Service Account Tokens

CIS Kubernetes Benchmark - Service Accounts

NIST Identity and Access Management

text

## **Deployment Commands:**

```bash
# 1. Commit and push the new lab structure
cd Kubernetes
git add .
git commit -m "Add CKS Lab 13 - Service Account Abuse Prevention"
git push origin main

# 2. Deploy via ArgoCD
kubectl apply -f gitops/clusters/cks-lab/applications/13-sa-abuse-setup.yaml
kubectl apply -f gitops/clusters/cks-lab/applications/13-sa-policies.yaml
kubectl apply -f gitops/clusters/cks-lab/applications/13-sa-testing.yaml
kubectl apply -f gitops/clusters/cks-lab/applications/13-sa-monitoring.yaml

# 3. Monitor deployment
argocd app sync 13-sa-abuse-setup
argocd app sync 13-sa-policies
argocd app sync 13-sa-testing
argocd app sync 13-sa-monitoring

# 4. Verify installation
kubectl get pods -n sa-security-system
kubectl get pods -n sa-security-test

# 5. Run security tests
kubectl create -f gitops/clusters/cks-lab/manifests/13-sa-abuse-prevention/testing/sa-abuse-tests.yaml

# 6. Check results
kubectl logs -n sa-security-test -l job-name=sa-abuse-test-suite --tail=50
This follows your exact pattern with:

Multiple ArgoCD applications for different components

Comprehensive security policies

Good/bad workload examples

Attack and defense scenarios

Admission control implementation

Monitoring and auditing setup

Complete documentation and exercises

The structure maintains consistency with your other labs while providing a complete service account security implementation.