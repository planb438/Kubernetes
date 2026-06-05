# Hint 2: Capabilities and Resource Management (Cost: 2 points)

## Linux Capabilities - Critical for Security

### Dangerous Capabilities to ALWAYS Drop
```yaml
capabilities:
  drop:
  - ALL                         # Start with none
  # Specifically drop these dangerous ones:
  - NET_RAW                     # Raw socket manipulation
  - SYS_ADMIN                   # Admin operations
  - SYS_MODULE                  # Load kernel modules
  - SYS_PTRACE                  # Debug other processes
  - SYS_RAWIO                   # Raw I/O access
  - SYS_TIME                    # Modify system time
Safe Capabilities for Specific Use Cases
yaml
capabilities:
  add:
  - NET_BIND_SERVICE    # Bind to ports < 1024 (web servers)
  - CHOWN               # Change file ownership (rarely needed)
  - DAC_OVERRIDE        # Bypass file permissions (use carefully)
  - FOWNER              # Bypass permission checks (use carefully)
  - SETGID              # Manipulate process GID
  - SETUID              # Manipulate process UID
Resource Management - Preventing DoS
Memory Limits (Critical)
yaml
resources:
  limits:
    memory: "256Mi"     # Container killed if exceeds
  requests:
    memory: "128Mi"     # Reserved for scheduling
CPU Limits (Important)
yaml
resources:
  limits:
    cpu: "200m"         # 0.2 CPU cores max
  requests:
    cpu: "100m"         # 0.1 CPU cores reserved
Calculating Resource Values
Monitor first: Use kubectl top pod to see usage

Add buffer: Request = average usage, Limit = 2x request

Consider spikes: Some apps need burst capacity

Health Probes - Application Monitoring
Liveness Probe (Is it running?)
yaml
livenessProbe:
  httpGet:
    path: /health
    port: 8080
  initialDelaySeconds: 30    # Wait for app to start
  periodSeconds: 10          # Check every 10 seconds
  timeoutSeconds: 5          # Fail if no response in 5s
  failureThreshold: 3        # Restart after 3 failures
Readiness Probe (Can it serve traffic?)
yaml
readinessProbe:
  httpGet:
    path: /ready
    port: 8080
  initialDelaySeconds: 5     # Check sooner than liveness
  periodSeconds: 5
  timeoutSeconds: 3
  failureThreshold: 1        # Remove from service quickly
Volume Security Best Practices
Never Use HostPath in Production
yaml
# BAD - Security Risk
volumes:
- name: host-tmp
  hostPath:
    path: /tmp

# GOOD - Use emptyDir
volumes:
- name: tmp
  emptyDir:
    medium: Memory          # Store in RAM, not disk
    sizeLimit: 100Mi        # Prevent unlimited growth
Read-Only Mounts Where Possible
yaml
volumeMounts:
- name: config
  mountPath: /etc/app/config
  readOnly: true            # Config files shouldn't be modified
Service Account Security
Dedicated Service Account
yaml
serviceAccountName: app-sa          # Not "default"
automountServiceAccountToken: false # Don't auto-mount token
Minimal RBAC
yaml
# Role with least privilege
rules:
- apiGroups: [""]
  resources: ["configmaps"]
  verbs: ["get"]
  resourceNames: ["app-config"]  # Specific resource only
Testing Your Configuration
Security Scan Commands
bash
# Check capabilities in running container
kubectl exec <pod> -- capsh --print

# Check effective capabilities
kubectl exec <pod> -- cat /proc/self/status | grep CapEff

# Test NET_BIND_SERVICE
kubectl exec <pod> -- nc -l -p 80 -w 1

# Test read-only root
kubectl exec <pod> -- touch /test.txt
# Should fail with "Read-only file system"
Resource Testing
bash
# Monitor resource usage
kubectl top pod <pod-name>

# Check resource configuration
kubectl describe pod <pod-name> | grep -A5 "Limits\|Requests"
Common Issues and Solutions
Permission denied on port 80: Add NET_BIND_SERVICE capability

Cannot write to /tmp: Mount emptyDir volume at /tmp

Health checks failing: Increase initialDelaySeconds

Container killed (OOM): Increase memory limits

Slow performance: Increase CPU requests/limits