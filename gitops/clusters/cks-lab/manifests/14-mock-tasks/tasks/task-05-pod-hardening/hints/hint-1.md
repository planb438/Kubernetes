# Hint 1: Security Context Fields (Cost: 2 points)

## Pod-Level Security Context
```yaml
spec:
  securityContext:
    runAsNonRoot: true      # Prevents root (UID 0)
    runAsUser: 10001        # Specific non-root UID
    runAsGroup: 10001       # Specific non-root GID
    fsGroup: 10001          # Volume ownership
    seccompProfile:
      type: RuntimeDefault  # Restrict system calls
Container-Level Security Context
yaml
containers:
- name: app
  securityContext:
    allowPrivilegeEscalation: false  # Critical for security
    privileged: false                # Never true in production
    readOnlyRootFilesystem: true     # Prevent writes to root FS
    runAsNonRoot: true               # Redundant but explicit
    runAsUser: 10001                 # Must match pod level
    capabilities:
      drop:                          # Start with no capabilities
      - ALL
      add:                           # Add only what's needed
      - NET_BIND_SERVICE            # For binding to ports < 1024
Key Security Fields Explained
runAsNonRoot vs runAsUser
runAsNonRoot: Boolean check (kubelet validates before start)

runAsUser: Specific UID (container runs with this UID)

Best practice: Use both for defense in depth

Capabilities Management
Drop ALL first: Start from clean slate

Add minimally: Only what application needs

NET_BIND_SERVICE: Required for web servers on ports 80/443

Dangerous to allow: NET_RAW, SYS_ADMIN, SYS_MODULE

Filesystem Security
readOnlyRootFilesystem: true

Mount writable directories: /tmp, /var/log, /var/run

Use emptyDir with Memory: For temporary data

Common Patterns
Web Server Configuration
yaml
securityContext:
  capabilities:
    drop: [ALL]
    add: [NET_BIND_SERVICE]
  readOnlyRootFilesystem: true
Application with Temporary Files
yaml
securityContext:
  readOnlyRootFilesystem: true
volumeMounts:
- name: tmp
  mountPath: /tmp
volumes:
- name: tmp
  emptyDir:
    medium: Memory
Testing Commands
bash
# Check security context
kubectl get pod <name> -o jsonpath='{.spec.containers[0].securityContext}'

# Check running user
kubectl exec <pod> -- id

# Check capabilities
kubectl exec <pod> -- cat /proc/self/status | grep Cap
Resources
Kubernetes Docs: https://kubernetes.io/docs/tasks/configure-pod-container/security-context/

CIS Benchmark: Section 5.7

NIST SP 800-190: Container Security