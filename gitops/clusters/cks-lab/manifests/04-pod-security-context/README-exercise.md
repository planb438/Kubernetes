Kubernetes/gitops/
├── clusters/
│   └── cks-lab/
│       ├── applications/
│       │   ├── 04-pod-security-context.yaml
│       │   ├── 04-psa-policies.yaml
│       │   └── 04-audit-tools.yaml
│       └── manifests/
│           └── 04-pod-security-context/
│               ├── namespace.yaml
│               ├── 01-run-as-non-root/
│               │   ├── good-pod.yaml
│               │   ├── bad-pod.yaml
│               │   └── test-job.yaml
│               ├── 02-readonly-rootfs/
│               ├── 03-seccomp-profile/
│               ├── 04-drop-capabilities/
│               ├── 05-user-group/
│               ├── comprehensive-example.yaml
│               ├── psa-policies.yaml
│               └── README-exercise.md
├── policies/
│   └── pod-security-standards/
│       ├── baseline.yaml
│       ├── restricted.yaml
│       └── privileged.yaml
└── tools/
    └── security-audit/
        ├── kube-bench-job.yaml
        └── kube-hunter-scan.yaml

markdown
# CKS Exercise 04: Pod Security Context Mastery

## Learning Objectives:
- Implement comprehensive pod security contexts
- Understand Pod Security Standards (PSS)
- Apply security context best practices
- Audit and validate security configurations

## Scenario:
You are securing a microservices deployment. Each service needs appropriate
security contexts based on its requirements.

## Tasks:

### Task 1: Deploy Security Lab
1. Sync the `cks-04-pod-security-context` application
2. Explore each security context example
3. Run test jobs to verify behaviors

### Task 2: Security Context Analysis
For each pod example, identify:
1. Which security contexts are applied
2. What security risks they mitigate
3. How they comply with PSS

### Task 3: Fix Vulnerable Deployment
Given a vulnerable deployment, apply security contexts to:
1. Run as non-root user
2. Implement read-only root filesystem
3. Apply seccomp profile
4. Drop unnecessary capabilities
5. Set appropriate user/group IDs

### Task 4: Create Custom Security Policy
Design a PodSecurityPolicy or Kyverno policy that:
1. Enforces runAsNonRoot
2. Requires seccomp profiles
3. Limits capabilities
4. Applies to specific namespaces

## Success Criteria:
- [ ] All example pods deployed successfully
- [ ] Security contexts understood and documented
- [ ] Vulnerable deployment secured
- [ ] Custom security policy created
- [ ] All configurations stored in Git

## Advanced Challenges:
1. Implement Pod Security Admission (PSA) webhook
2. Create security context auto-remediation
3. Build security compliance dashboard
4. Integrate with CI/CD pipeline
🚀 DEPLOYMENT WORKFLOW:
In ArgoCD UI:
text
Application Name: pod-security-lab
Path: gitops/clusters/cks-lab/manifests/04-pod-security-context
Namespace: pod-security-lab
Sync Options: CreateNamespace=true
Testing:
bash
# Test each security context
kubectl apply -f 01-run-as-non-root/bad-pod.yaml  # Should fail
kubectl apply -f 01-run-as-non-root/good-pod.yaml # Should succeed

# Audit current pods
kubectl get pods -n pod-security-lab -o json | \
  jq '.items[].spec.securityContext'
💡 KEY LEARNING POINTS:
runAsNonRoot: Prevents running as UID 0

readOnlyRootFilesystem: Immutable containers

seccompProfile: System call filtering

capabilities.drop: Principle of least privilege

fsGroup: Volume permissions management

🔧 PRODUCTION RECOMMENDATIONS:
Start with baseline: Apply to all namespaces

Gradual enforcement: Audit → Warn → Enforce

Exception process: Document required exceptions

Regular audits: Scan for policy violations

Want me to:

Add vulnerability scanning for security contexts?

Create policy violation dashboard?

Add CI/CD pipeline for security validation?

Create cheat sheet of security context combinations?

This transforms your security context lab into a comprehensive, production-ready security module!