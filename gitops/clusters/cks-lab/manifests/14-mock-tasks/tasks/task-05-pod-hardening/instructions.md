# Mock CKS Exam - Task 5: Pod Security Hardening

## Task Description
A security audit revealed multiple vulnerabilities in your production workloads. The audit report identified containers running with excessive privileges, unnecessary capabilities, and insecure configurations.

Your mission: Harden the existing `frontend-app` deployment to meet security requirements and compliance standards.

## Requirements
1. **Analyze the vulnerable pod** in `provided-files/vulnerable-pod.yaml`
2. **Create a hardened version** that addresses all security findings:
   - Run as non-root user (UID > 10000)
   - Disable privilege escalation
   - Drop ALL capabilities, then add only: `NET_BIND_SERVICE`
   - Set read-only root filesystem
   - Set appropriate resource limits
   - Add security context at both pod and container level
   - Remove unnecessary volume mounts
   - Add liveness and readiness probes

3. **Apply security policies** to enforce these standards cluster-wide
4. **Test the hardened pod** for functionality and security
5. **Verify compliance** with provided security standards

## Security Findings to Address
1. **Privilege Issues**: Running as root, privilege escalation allowed
2. **Capabilities**: NET_RAW, SYS_ADMIN capabilities present
3. **Filesystem**: Writable root filesystem
4. **Resources**: No memory/CPU limits
5. **Probes**: No health checks
6. **Volumes**: HostPath mounts with write access

## Compliance Requirements
- **CIS Kubernetes Benchmark** v1.8
- **NIST SP 800-190** Application Container Security Guide
- **PCI-DSS** Requirement 2.2
- **Company Security Policy** v3.0

## Constraints
- Time limit: 18 minutes
- Points: 22/100
- Must maintain application functionality
- Cannot modify application code
- Must use Kubernetes-native solutions
- Document all security decisions

## Success Criteria
- Hardened pod passes security scanner
- Application remains functional
- All security findings addressed
- Compliance report shows no critical issues
- Resource usage within limits
- Pod can be monitored properly

## Available Hints (cost: 2 points each)
1. Hint 1: Security context fields and their purposes
2. Hint 2: Capabilities management and seccomp profiles