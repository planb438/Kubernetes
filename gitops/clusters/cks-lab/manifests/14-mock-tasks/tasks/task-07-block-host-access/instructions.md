# Mock CKS Exam - Task 7: Block Host Access and Privilege Escalation

## Task Description
A security incident investigation revealed that an attacker compromised a container and gained host-level access through insecure configurations. Multiple workloads were found with dangerous host access permissions.

Your mission: Implement comprehensive security controls to prevent containers from accessing host resources and escalating privileges.

## Requirements
1. **Create a Kyverno ClusterPolicy** that:
   - Blocks ALL pods with `hostNetwork`, `hostPID`, or `hostIPC` set to true
   - Prevents `hostPath` volume mounts except for specific allowlisted paths
   - Denies privileged containers in ALL namespaces (except kube-system with approval)
   - Restricts containers from running as root (UID 0)
   - Blocks pods with `allowPrivilegeEscalation: true`

2. **Configure Pod Security Admission (PSA)** to:
   - Set baseline mode for all namespaces
   - Set restricted mode for production namespaces
   - Create exemptions for specific system workloads
   - Audit violations before enforcement

3. **Implement monitoring** for:
   - Attempted host access violations
   - Privilege escalation attempts
   - Policy violations and audit logs
   - Real-time alerts for security incidents

4. **Create remediation plan** for existing violations

## Security Incidents to Prevent
1. **Host Path Mount Escape**: Container mounted `/` and escaped to host
2. **Host Network Sniffing**: Container using host network to sniff traffic
3. **Privileged Container Escape**: Privileged container escaped to host
4. **PID Namespace Attack**: Access to host processes via hostPID
5. **IPC Namespace Attack**: Shared memory attacks via hostIPC

## Compliance Requirements
- **CIS Kubernetes 1.8**: Sections 5.2.1 - 5.2.8
- **NIST SP 800-190**: Container Security Guidelines
- **PCI-DSS Requirement 2.2**: Harden configurations
- **Company Security Policy**: No host access in production

## Technical Requirements
1. **Policy must be cluster-wide** with namespace-specific exceptions
2. **Use Pod Security Standards** (Baseline, Restricted)
3. **Implement admission webhook** for real-time blocking
4. **Create audit trail** of all violations
5. **Allow exceptions** with proper approval workflow
6. **Integrate with existing** security monitoring

## Constraints
- Time limit: 20 minutes
- Points: 24/100
- Must maintain cluster functionality
- System pods in kube-system may need exemptions
- Monitoring tools must be lightweight
- Policies must be documented and tested

## Success Criteria
- No pods can mount arbitrary host paths
- Host namespace sharing completely blocked
- Privileged containers prevented
- Root execution blocked in production
- Policy violations are logged and alerted
- Existing violations are remediated
- Compliance reports generated

## Available Hints (cost: 2 points each)
1. Hint 1: Kyverno policy structure for host access blocking
2. Hint 2: Pod Security Admission configuration