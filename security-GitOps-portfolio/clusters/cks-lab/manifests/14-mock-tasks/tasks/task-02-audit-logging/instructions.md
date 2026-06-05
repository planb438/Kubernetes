task-02-audit-logging/
├── instructions.md
├── provided-files/
│   ├── cluster-setup.yaml
│   └── initial-audit-policy.yaml
├── solution/
│   ├── namespace.yaml
│   ├── audit-policy.yaml
│   └── verification-script.sh
├── test/
│   ├── pre-conditions.yaml
│   ├── verification-job.yaml
│   └── expected-output.yaml
└── hints/
    ├── hint-1.md
    └── hint-2.md

# Mock CKS Exam - Task 2: Configure Kubernetes Audit Logging

## Task Description
You are a Kubernetes security administrator. The security team requires audit logging for compliance purposes. You need to:

1. **Configure audit logging** for the `finance` namespace to log:
   - All `Request` level activities for secrets
   - `Metadata` level for configmaps and pods
   - No logging for `get` operations on configmaps (to reduce noise)

2. **Apply the audit policy** without restarting control plane nodes
3. **Test the configuration** by accessing a test secret
4. **Verify logs** contain the expected audit entries

## Requirements
- Create namespace: `finance`
- Create audit policy meeting requirements above
- Apply policy using a non-disruptive method
- Create test secret: `audit-test-secret` in `finance` namespace
- Generate audit events by accessing the secret
- Verify audit logs contain the expected entries

## Constraints
- **DO NOT** modify `/etc/kubernetes/manifests/kube-apiserver.yaml` directly
- **DO NOT** restart control plane nodes
- Use `kubectl` commands only (no SSH to nodes)
- Time limit: 15 minutes
- Points: 20/100

## Success Criteria
- Audit policy correctly filters by resource type and verb
- Secret access generates `Request` level logs
- Configmap `get` operations are not logged
- No cluster downtime during implementation

## Provided Files
- `cluster-setup.yaml`: Existing cluster configuration
- `initial-audit-policy.yaml`: Baseline audit policy (needs modification)

## Hints Available: 2 (cost: 3 points each)



Key Learning Points for CKS Exam
Know audit policy syntax - Levels: None, Metadata, Request, RequestResponse

Understand namespace/verb/resource filtering

Be comfortable with control plane modifications (in exam environment)

Verify your work - Always check logs after configuration

Clean up properly - Remove test resources

Recommendations for Your Mock Exam
Keep Task 2 as-is for node-level skills testing

Add a note explaining exam vs production differences

Create alternative solution for GitOps environments

Add time pressure - 15 minutes for completion

Include verification script that checks:

Policy file exists in correct location

kube-apiserver args are updated

Audit logs contain expected entries

Next Steps
Would you like me to:

Create Task 3 (Network Policy, Pod Security, etc.)?

Build the scoring dashboard for tracking progress?

Enhance Task 2 with more realistic exam constraints?

Create a complete exam simulation with time tracking?

Your audit logging task is well-structured for CKS preparation. The key is balancing exam realism (node access) with GitOps principles (declarative configuration).

