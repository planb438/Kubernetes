# 📄 CKS 1-Page YAML Cheat Sheet – High-Frequency Patterns

## 🔐 RBAC – Least Privilege (List Pods Only)

```yaml
apiVersion: v1
kind: ServiceAccount
metadata:
  name: reader
  namespace: dev
---
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: pod-read
  namespace: dev
rules:
- apiGroups: [""]
  resources: ["pods"]
  verbs: ["get", "list"]
---
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: bind-pod-read
  namespace: dev
subjects:
- kind: ServiceAccount
  name: reader
  namespace: dev
roleRef:
  kind: Role
  name: pod-read
  apiGroup: rbac.authorization.k8s.io
```

## 🚫 PodSecurityContext – Non-root, Drop Capabilities

```yaml
securityContext:
  runAsUser: 1000
  runAsNonRoot: true
  allowPrivilegeEscalation: false
  capabilities:
    drop: ["ALL", "NET_RAW"]
```

## 🛡️ NetworkPolicy – Allow by Namespace & Label

```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-client
  namespace: webapp
spec:
  podSelector:
    matchLabels:
      role: web
  policyTypes:
  - Ingress
  ingress:
  - from:
    - namespaceSelector:
        matchLabels:
          name: client-ns
      podSelector:
        matchLabels:
          access: granted
```

## 🔍 Audit Policy – Log Secrets Access

```yaml
apiVersion: audit.k8s.io/v1
kind: Policy
rules:
- level: Metadata
  resources:
  - group: ""
    resources: ["secrets"]
  namespaces: ["audit-ns"]
```

## 🛡️ Kyverno – Block Privileged + hostNetwork

```yaml
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: block-host-access
spec:
  validationFailureAction: enforce
  background: false
  rules:
  - name: deny-hostnetwork-privileged
    match:
      any:
      - resources:
          kinds: ["Pod"]
    validate:
      message: "No hostNetwork or privileged allowed"
      deny:
        conditions:
        - key: "{{ request.object.spec.hostNetwork }}"
          operator: Equals
          value: true
        - key: "{{ request.object.spec.containers[].securityContext.privileged }}"
          operator: Equals
          value: true
```

## 🔐 Cosign verifyImages (Kyverno)

```yaml
verifyImages:
- image: "docker.io/YOURNAME/*"
  keyRef:
    name: cosign-pubkey
    namespace: your-ns
    key: cosign.pub
  mutateDigest: true
```

## 🧱 RuntimeClass (gVisor)

```yaml
apiVersion: node.k8s.io/v1
kind: RuntimeClass
metadata:
  name: gvisor
handler: runsc
```

## 📦 AppArmor Annotation

```yaml
metadata:
  annotations:
    container.apparmor.security.beta.kubernetes.io/app: localhost/deny-tmp
```

---

💡 Keep this in your exam notepad. Use `kubectl explain` to fill in unknowns.

```bash
kubectl explain pod.spec.securityContext
kubectl create rolebinding --dry-run=client -o yaml ...
```
