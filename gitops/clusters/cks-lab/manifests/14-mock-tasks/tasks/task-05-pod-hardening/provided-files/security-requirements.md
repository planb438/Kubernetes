# Security Hardening Requirements for Production Workloads

## Mandatory Requirements (Must Implement)

### 1. Identity and Access Control
- **Non-root execution**: All containers must run as non-root users (UID > 10000)
- **User namespace**: Use defined UID/GID, not 0
- **Service accounts**: Dedicated service accounts with minimal permissions

### 2. Privilege Management
- **Privilege escalation**: Must be disabled (`allowPrivilegeEscalation: false`)
- **Privileged containers**: Not allowed in production
- **Host namespace sharing**: Disabled (hostNetwork, hostPID, hostIPC)

### 3. Linux Capabilities
- **Default action**: Drop ALL capabilities
- **Allowed capabilities**: Only explicitly required capabilities
- **Prohibited**: NET_RAW, SYS_ADMIN, SYS_MODULE, SYS_PTRACE
- **Required for web servers**: NET_BIND_SERVICE (to bind to ports < 1024)

### 4. Filesystem Security
- **Root filesystem**: Read-only (`readOnlyRootFilesystem: true`)
- **Volume mounts**: Only necessary directories writable
- **HostPath volumes**: Prohibited in production
- **Secret storage**: Use Kubernetes Secrets, not environment variables

### 5. Resource Management
- **Memory limits**: Must be set for all containers
- **CPU limits**: Must be set for all containers
- **Memory requests**: Must be set for all containers
- **CPU requests**: Must be set for all containers

### 6. Health Monitoring
- **Liveness probes**: Required for all long-running containers
- **Readiness probes**: Required for all service-facing containers
- **Startup probes**: Recommended for slow-starting containers

### 7. Network Security
- **Network policies**: Restrict ingress/egress traffic
- **Port exposure**: Only necessary ports
- **Localhost access**: Limit to required services

## Compliance Standards

### CIS Kubernetes Benchmark
- 5.2.1: Ensure that the --anonymous-auth argument is set to false
- 5.2.6: Ensure that the --authorization-mode argument is not set to AlwaysAllow
- 5.2.7: Ensure that the --authorization-mode argument includes Node
- 5.2.8: Ensure that the --authorization-mode argument includes RBAC

### NIST SP 800-190
- SC-1: System and Communications Protection
- AC-3: Access Enforcement
- AU-2: Audit Events

### PCI-DSS Requirements
- 2.2: Develop configuration standards for all system components
- 6.1: Establish a process to identify security vulnerabilities
- 6.2: Ensure all systems have latest security patches

## Testing Requirements
1. **Security scan**: Pass Trivy/Grype scan with no CRITICAL vulnerabilities
2. **Functionality test**: Application serves traffic correctly
3. **Compliance check**: Meets all mandatory requirements
4. **Penetration test**: Resists common container escape techniques