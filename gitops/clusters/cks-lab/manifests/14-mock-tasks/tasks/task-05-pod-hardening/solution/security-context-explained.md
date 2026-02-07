# Security Context Implementation - Explained

## Pod-Level Security Context
```yaml
securityContext:
  runAsNonRoot: true      # Prevents running as root (C-01)
  runAsUser: 10001        # Non-root UID > 10000
  runAsGroup: 10001       # Non-root GID
  fsGroup: 10001          # Filesystem group for volumes
  seccompProfile:
    type: RuntimeDefault  # Default seccomp profile (H-04)




Why These Values?
runAsNonRoot: Boolean check before container starts

runAsUser/runAsGroup: Specific non-root IDs (not 0)

fsGroup: Ensures volumes are accessible by container user

seccompProfile: Restricts system calls

Container-Level Security Context
yaml
securityContext:
  allowPrivilegeEscalation: false  # C-02 Fixed
  privileged: false                # Never allow privileged
  readOnlyRootFilesystem: true     # C-05 Fixed
  capabilities:
    drop:                          # C-03 Fixed
    - ALL
    add:
    - NET_BIND_SERVICE            # Required for ports < 1024
Capabilities Management
Drop ALL first: Start with no capabilities

Add only needed: NET_BIND_SERVICE for web servers

Dangerous capabilities to avoid:

NET_RAW: Raw socket manipulation

SYS_ADMIN: Admin operations

SYS_MODULE: Load kernel modules

SYS_PTRACE: Debug other processes

Resource Management
yaml
resources:
  requests:
    memory: "128Mi"
    cpu: "100m"
  limits:
    memory: "256Mi"
    cpu: "200m"
Why Set Both?
Requests: Reserved resources for scheduling

Limits: Maximum allowed (prevents DoS)

Health Probes
yaml
livenessProbe:    # Is container running?
readinessProbe:   # Is container ready to serve?
startupProbe:     # Has container started?
Configuration Guidelines
Initial delays: Account for startup time

Timeouts: Shorter than period

Failure thresholds: Appropriate for application

Volume Security
yaml
volumeMounts:
- mountPath: /etc/nginx/nginx.conf
  readOnly: true           # Config files read-only
volumes:
- emptyDir:
    medium: Memory        # Store in memory, not disk
Best Practices
No HostPath volumes in production

emptyDir with Memory for temporary data

ConfigMaps/Secrets for configuration

Read-only mounts where possible

Service Account Security
yaml
serviceAccountName: frontend-sa
automountServiceAccountToken: false
Why Dedicated Service Account?
Principle of least privilege

Audit trail for actions

No default service account usage

Token management control

Affinity Rules
yaml
affinity:
  podAntiAffinity:
    preferredDuringSchedulingIgnoredDuringExecution:
    - weight: 100
      podAffinityTerm:
        topologyKey: kubernetes.io/hostname
Benefits
High availability: Pods on different nodes

Resource distribution: Avoids node overload

Failure isolation: Single node failure doesn't take all pods

Compliance Mapping
Security Control	CIS Benchmark	NIST Control	PCI-DSS
Non-root user	5.7.1	AC-3	2.2
No privilege escalation	5.7.5	AC-6	2.2
Capabilities dropped	-	AC-3	2.2
Read-only root FS	-	SC-28	2.2
Resource limits	-	SC-6	6.1
Health checks	-	SI-7	6.2
Testing Commands
bash
# Check security context
kubectl get pod <pod-name> -o jsonpath='{.spec.securityContext}'

# Check capabilities
kubectl exec <pod-name> -- cat /proc/self/status | grep Cap

# Test functionality
kubectl exec <pod-name> -- curl -I localhost

# Check resource usage
kubectl top pod <pod-name>
Common Issues and Solutions
Permission denied: Check UID/GID and volume permissions

Port binding failed: Add NET_BIND_SERVICE capability

Read-only filesystem errors: Mount writable directories

Health check failures: Adjust timeouts and paths