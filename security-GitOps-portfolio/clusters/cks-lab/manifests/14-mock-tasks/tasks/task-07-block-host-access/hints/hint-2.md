# Hint 2: Pod Security Admission Configuration (Cost: 2 points)

## Pod Security Standards

### Three Policy Levels
1. **Privileged**: Unrestricted policy, provides widest possible level of permissions
2. **Baseline**: Minimally restrictive policy which prevents known privilege escalations
3. **Restricted**: Heavily restricted policy, following current Pod hardening best practices

## Namespace Configuration

### Label-Based Configuration
```yaml
apiVersion: v1
kind: Namespace
metadata:
  name: production
  labels:
    pod-security.kubernetes.io/enforce: restricted
    pod-security.kubernetes.io/enforce-version: latest
    pod-security.kubernetes.io/audit: restricted
    pod-security.kubernetes.io/audit-version: latest
    pod-security.kubernetes.io/warn: restricted
    pod-security.kubernetes.io/warn-version: latest
Label Meanings
enforce: Policy violations will cause the pod to be rejected

audit: Policy violations will trigger audit events but pods are allowed

warn: Policy violations will trigger user-facing warnings but pods are allowed

PSA Admission Configuration
Admission Configuration File
yaml
apiVersion: apiserver.config.k8s.io/v1
kind: AdmissionConfiguration
plugins:
- name: PodSecurity
  configuration:
    apiVersion: pod-security.admission.config.k8s.io/v1
    kind: PodSecurityConfiguration
    defaults:
      enforce: "baseline"
      enforce-version: "latest"
      audit: "restricted"
      audit-version: "latest"
      warn: "restricted"
      warn-version: "latest"
    exemptions:
      usernames: []
      runtimeClasses: []
      namespaces:
      - "kube-system"
      - "gatekeeper-system"
Checking Current Configuration
View Namespace Labels
bash
# Check all namespace PSA labels
kubectl get namespaces --show-labels | grep pod-security

# Check specific namespace
kubectl get namespace production -o jsonpath='{.metadata.labels}' | jq .
Test PSA Enforcement
bash
# Test restricted policy
cat <<EOF | kubectl apply -f - --dry-run=server
apiVersion: v1
kind: Pod
metadata:
  name: test-psa
  namespace: production
spec:
  containers:
  - name: test
    image: alpine
    securityContext:
      runAsUser: 0
EOF
PSA with Kyverno Integration
Layered Security Approach
PSA: Baseline policy enforcement

Kyverno: Custom rules and exceptions

Webhooks: Complex validation logic

Example Integration
yaml
# PSA handles baseline, Kyverno adds specific rules
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: psa-enhanced
spec:
  rules:
  - name: enhance-psa-restricted
    match:
      resources:
        namespaces:
        - production
    # Add rules beyond PSA restricted level
Migration Strategy
1. Audit Phase
bash
# Apply warn labels first
kubectl label namespace production \
  pod-security.kubernetes.io/warn=restricted \
  pod-security.kubernetes.io/warn-version=latest
2. Enforcement Phase
bash
# After fixing violations, enforce
kubectl label namespace production \
  pod-security.kubernetes.io/enforce=restricted \
  pod-security.kubernetes.io/enforce-version=latest \
  --overwrite
Common PSA Violations
Restricted Policy Violations
yaml
# These will be blocked:
spec:
  securityContext:
    runAsUser: 0  # Running as root
  
  containers:
  - securityContext:
      privileged: true  # Privileged container
      capabilities:
        add: ["NET_RAW"]  # Added capabilities
Baseline Policy Violations
yaml
# These will be blocked:
spec:
  hostNetwork: true  # Host network
  hostPID: true      # Host PID namespace
  hostIPC: true      # Host IPC namespace
  
  volumes:
  - hostPath:        # HostPath volumes
      path: /etc
Exemption Strategies
1. Namespace Exemptions
yaml
exemptions:
  namespaces:
  - "kube-system"
  - "monitoring"
2. Runtime Class Exemptions
yaml
exemptions:
  runtimeClasses:
  - "gvisor"
  - "kata"
3. User Exemptions (Use with caution)
yaml
exemptions:
  usernames:
  - "system:serviceaccount:kube-system:cluster-admin"
Monitoring and Compliance
Check PSA Violations
bash
# View audit events
kubectl get events --field-selector reason=FailedCreate

# Check API server audit logs
kubectl logs -n kube-system kube-apiserver-node-1 | grep -i podsecurity

# Use kubectl explain for policy details
kubectl explain pod.spec.securityContext
Compliance Reporting
bash
# Generate PSA compliance report
kubectl get pods --all-namespaces -o json | \
  jq -r '.items[] | select(.spec.securityContext == null) | .metadata.namespace + "/" + .metadata.name'
Best Practices
1. Start with Audit Mode
Apply warn labels first

Fix violations before enforcement

Use audit events for tracking

2. Gradual Rollout
Start with non-critical namespaces

Monitor for business impact

Adjust policies as needed

3. Documentation
Document all exemptions

Maintain policy change log

Train development teams

4. Continuous Improvement
Regular policy reviews

Update to latest standards

Integrate with CI/CD