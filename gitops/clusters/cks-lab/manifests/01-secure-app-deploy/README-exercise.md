markdown
# CKS Exercise 01: Secure Application Deployment with GitOps

## Learning Objectives:
- Deploy applications using GitOps principles
- Implement Kubernetes security policies with Kyverno
- Understand policy enforcement workflow
- Practice secure application configuration

## Scenario:
You are a platform engineer tasked with deploying a Node.js application
with security best practices enforced via policy-as-code.

## Tasks:

### Task 1: Deploy the Secure Application
1. Sync the `cks-01-secure-app-deploy` application in ArgoCD
2. Verify the application deploys successfully
3. Check that Kyverno policies are applied

### Task 2: Test Policy Enforcement
1. Try to deploy the bad pod:
   ```bash
   kubectl apply -f test-bad-pod.yaml
Observe the rejection message

Deploy the good pod and verify it works

Task 3: Enhance Security
Add a NetworkPolicy to restrict traffic

Implement resource quota for the namespace

Add a Kyverno policy to require image provenance

Task 4: GitOps Workflow
Make a security improvement in the Git repo

Create a pull request

Merge and observe ArgoCD auto-sync

Verify the change is applied

Success Criteria:
Application deployed via GitOps

Kyverno policies enforced

Bad pod rejected

Good pod accepted

Security improvements committed to Git

Advanced Challenges:
Add OPA/Gatekeeper policies alongside Kyverno

Implement admission control webhook

Create a security dashboard

Add automated security scanning to CI/CD

text

---

## 🚀 **DEPLOYMENT WORKFLOW:**

### **Step 1: Bootstrap (One-time)**
```bash
# Apply the bootstrap application
kubectl apply -f https://raw.githubusercontent.com/planb438/Kubernetes/main/gitops/bootstrap/cks-bootstrap.yaml
Step 2: Learning Flow
text
Student/User:
1. Forks your repo
2. Deploys ArgoCD apps
3. Completes exercises
4. Submits PR with solutions
5. Gets automated feedback
Step 3: Automated Testing (GitHub Actions)
yaml
# .github/workflows/test-cks-lab.yaml
name: Test CKS Lab 01
on: [pull_request]
jobs:
  test:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v3
    - name: Test Kyverno Policy
      run: |
        # Simulate policy enforcement
        kubectl apply --dry-run=server -f test-bad-pod.yaml
        # Should fail
💡 WHY THIS IS BETTER:
Original: Manual script
bash
./deploy.sh  # One-time, manual, no audit trail
GitOps Version:
text
Git Commit → ArgoCD → Cluster
     ↓
Audit Trail + Repeatable + Scalable + Collaborative
🎯 IMMEDIATE ACTION:
Create the gitops/ directory in your repo

Add the Application manifests (start with just one)

Test deployment via ArgoCD

Document the process in README