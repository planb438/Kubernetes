markdown
# CKS Exercise 02: OPA Gatekeeper Policy Enforcement

## Learning Objectives:
- Deploy and configure OPA Gatekeeper via GitOps
- Create ConstraintTemplates with Rego policies
- Implement Constraints for security enforcement
- Understand admission controller workflow

## Scenario:
Your organization is adopting OPA Gatekeeper for policy-as-code.
You need to implement policies to block privileged containers.

## Tasks:

### Task 1: Deploy Gatekeeper via GitOps
1. Sync the `cks-02-opa-gatekeeper` application in ArgoCD
2. Wait for Gatekeeper pods to be ready
3. Verify ConstraintTemplate CRD is registered

### Task 2: Test Policy Enforcement
1. Try to deploy the bad pod:
   ```bash
   kubectl apply -f test-bad-pod.yaml
Observe the rejection message from Gatekeeper

Deploy the good pod and verify it's accepted

Task 3: Enhance Policies
Extend the policy to also block:

HostPID, HostIPC, HostNetwork usage

Containers running as root (runAsUser: 0)

Containers with dangerous capabilities (NET_RAW, SYS_ADMIN)

Create a new ConstraintTemplate for these rules

Task 4: GitOps Workflow
Add a new policy to your Git repository

Create a pull request with policy changes

Merge and observe ArgoCD auto-sync

Test the new policy enforcement

Success Criteria:
Gatekeeper deployed via GitOps

ConstraintTemplate created successfully

Constraint applied and enforcing

Bad pod rejected with clear error message

Good pod accepted

Policies version-controlled in Git

Advanced Challenges:
Implement mutation policies to auto-fix issues

Create dashboard for policy violations

Set up policy exemptions for specific workloads

Integrate with CI/CD pipeline for policy testing

text

---

## 🚀 **DEPLOYMENT WORKFLOW:**

### **Step 1: Create Apps in ArgoCD UI**

**App 1: Gatekeeper**
Name: gatekeeper-system
Repo: https://github.com/open-policy-agent/gatekeeper
Path: deploy/gatekeeper
Revision: release-3.15
Namespace: gatekeeper-system

text

**App 2: Gatekeeper Policies**
Name: gatekeeper-policies
Repo: https://github.com/planb438/Kubernetes.git
Path: gitops/clusters/cks-lab/manifests/02-opa-gatekeeper
Namespace: gatekeeper-system

text

**App 3: CKS Lab Namespace**
Name: cks-gatekeeper-lab
Path: gitops/clusters/cks-lab/manifests/02-opa-gatekeeper
Namespace: cks-gatekeeper-lab
Directory Include: namespace.yaml

text

### **Step 2: Sync Order**
1. **Gatekeeper** first (wait for pods ready)
2. **Policies** second (requires Gatekeeper CRDs)
3. **Namespace** third

### **Step 3: Testing**
```bash
# Test bad pod (should fail)
kubectl apply -f test-bad-pod.yaml

# Test good pod (should succeed)
kubectl apply -f test-good-pod.yaml

# Check Gatekeeper logs
kubectl logs -n gatekeeper-system deployment/gatekeeper-audit
🔧 TROUBLESHOOTING:
If Gatekeeper pods fail:
bash
# Check image pull issues
kubectl describe pod -n gatekeeper-system -l control-plane=controller-manager

# Use specific image tag
kubectl set image deployment/gatekeeper-controller-manager -n gatekeeper-system \
  manager=openpolicyagent/gatekeeper:v3.15.0
If policies not working:
bash
# Check ConstraintTemplate status
kubectl get constrainttemplate

# Check Constraint status
kubectl get k8sdisallowedprivileged

# Check Gatekeeper webhook
kubectl get validatingwebhookconfiguration gatekeeper-validating-webhook-configuration
💡 COMPARISON WITH KYVERNO LAB:
Kyverno (Lab 01):

YAML-based policies

Built-in Kubernetes CRDs

Simpler for basic policies

OPA Gatekeeper (Lab 02):

Rego language policies

More powerful/expressive

Industry standard for complex policies

Learning progression: Start with Kyverno, graduate to OPA Gatekeeper.

🎯 NEXT STEP:
Convert the install-gatekeeper.sh script to:

GitOps applications (done above)

GitHub Actions workflow for testing

Documentation for learners

Solution branch with advanced policies

Want me to:

Create GitHub Actions workflow for this lab?

Add solution examples with advanced Rego policies?

Create comparison chart between Kyverno vs OPA Gatekeeper?

Add monitoring setup for policy violations?

This transforms your OPA Gatekeeper lab into an interactive, production-ready GitOps learning module!

