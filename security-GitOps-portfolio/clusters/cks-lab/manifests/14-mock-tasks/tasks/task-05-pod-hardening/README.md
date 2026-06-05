task-05-pod-hardening/
├── instructions.md
├── provided-files/
│   ├── vulnerable-pod.yaml
│   ├── security-requirements.md
│   ├── compliance-standards.yaml
│   ├── existing-workloads/
│   │   ├── frontend-deployment.yaml
│   │   ├── backend-deployment.yaml
│   │   └── database-statefulset.yaml
│   └── security-audit-findings.md
├── solution/
│   ├── hardened-pod.yaml
│   ├── security-context-explained.md
│   ├── capability-check.sh
│   ├── security-policy.yaml
│   ├── remediation-script.sh
│   └── hardening-validation.sh
├── test/
│   ├── verification-job.yaml
│   ├── security-scanner.yaml
│   ├── compliance-report.yaml
│   └── penetration-test.yaml
├── hints/
│   ├── hint-1.md
│   └── hint-2.md
└── README.md

# Task 5: Pod Security Hardening

## Overview
This task tests your ability to secure Kubernetes pods by implementing comprehensive security contexts, managing Linux capabilities, setting resource limits, and following security best practices.

## Learning Objectives
- Understand Kubernetes security context fields
- Implement principle of least privilege for capabilities
- Configure resource limits to prevent DoS attacks
- Add health probes for application monitoring
- Follow security best practices for production workloads
- Address common container security vulnerabilities

## Prerequisites
- Basic understanding of Linux capabilities
- Familiarity with Kubernetes Deployment specifications
- Understanding of container security concepts
- Knowledge of compliance standards (CIS, NIST, PCI-DSS)

## Key Security Concepts

### 1. Non-Root Execution
Containers should never run as root (UID 0). Use dedicated non-root users with UID > 10000.

### 2. Capability Management
Drop ALL capabilities by default, then add only specifically required capabilities.

### 3. Filesystem Security
Use read-only root filesystems with specific writable directories mounted.

### 4. Resource Management
Set both requests (for scheduling) and limits (for enforcement) for CPU and memory.

### 5. Health Monitoring
Implement liveness, readiness, and startup probes for application health.

## Task Structure
- `instructions.md`: Complete scenario with security audit findings
- `provided-files/`: Vulnerable pod, security requirements, compliance standards
- `solution/`: Hardened pod implementation and explanation
- `test/`: Verification, security scanning, and compliance checking
- `hints/`: Guided assistance (with point cost)

## Time Management
- Recommended time: 18 minutes
- Points: 22/100
- Hint cost: 2 points each

## Success Criteria
- All critical security findings addressed
- Pod runs as non-root user
- Dangerous capabilities removed
- Resource limits properly set
- Health probes implemented
- No HostPath volumes used
- Compliance with security standards

## Testing Strategy
1. **Security validation**: Check security context configuration
2. **Functionality test**: Ensure application works correctly
3. **Capability check**: Verify only required capabilities present
4. **Resource verification**: Confirm limits and requests set
5. **Compliance audit**: Check against CIS, NIST, PCI-DSS standards

## Related CKS Domains
- Cluster Hardening
- System Hardening
- Supply Chain Security
- Monitoring, Logging and Runtime Security

## Real-World Application
- Production workload security
- Compliance requirements implementation
- Security incident response
- Audit finding remediation
- Security baseline establishment

## Common Pitfalls to Avoid
1. Forgetting to set `allowPrivilegeEscalation: false`
2. Not dropping ALL capabilities first
3. Using `:latest` image tags
4. Missing resource limits
5. No health probes
6. Using HostPath volumes
7. Running as root or low UID

## References
- Kubernetes Security Context: https://kubernetes.io/docs/tasks/configure-pod-container/security-context/
- CIS Kubernetes Benchmark: https://www.cisecurity.org/benchmark/kubernetes
- NIST SP 800-190: Application Container Security Guide
- Linux Capabilities: https://man7.org/linux/man-pages/man7/capabilities.7.html