# Security Incident Report: Container to Host Escalation

## Incident Summary
**Date**: 2024-01-15  
**Severity**: CRITICAL  
**Affected Namespaces**: production, monitoring  
**Root Cause**: Insecure container configurations allowing host access

## Incident Timeline
- **14:30**: Attacker gains initial access via web application vulnerability
- **14:32**: Attacker explores container, finds writable hostPath mount
- **14:35**: Attacker writes malicious binary to host via mounted volume
- **14:40**: Attacker executes binary on host, gains root access
- **14:45**: Attacker moves laterally to other nodes via SSH keys

## Attack Vectors Identified

### 1. HostPath Volume Escape
**Workload**: log-collector in production namespace  
**Vulnerability**: Mounted `/var/log` with write access  
**Impact**: Attacker wrote backdoor to host filesystem  
**CVE Equivalent**: CVE-2021-25741 - Kubernetes hostPath volume escape

### 2. Host Network Sniffing
**Workload**: node-monitor in monitoring namespace  
**Vulnerability**: `hostNetwork: true`  
**Impact**: Attacker sniffed cluster network traffic  
**CVE Equivalent**: CVE-2020-8554 - Kubernetes MITM via hostNetwork

### 3. Privileged Container Escape
**Workload**: device-manager in production namespace  
**Vulnerability**: `privileged: true`  
**Impact**: Attacker escaped container via privileged capabilities  
**CVE Equivalent**: CVE-2019-5736 - runC container escape

### 4. Host PID Namespace Attack
**Workload**: legacy-app in development namespace  
**Vulnerability**: `hostPID: true`  
**Impact**: Attacker accessed host processes and credentials  
**CVE Equivalent**: CVE-2021-25742 - Kubernetes hostPID attack

## Technical Details

### Compromised Configurations
```yaml
# Found in cluster configurations:
hostNetwork: true  # 8 workloads
hostPID: true      # 3 workloads  
hostIPC: true      # 2 workloads
hostPath volumes:  # 12 workloads
privileged: true   # 5 workloads
runAsUser: 0       # 15 workloads

Attack Path
Initial access via application vulnerability (CVE-2023-12345)

Container enumeration found hostPath mount

Write malicious payload to /var/log/.backdoor.sh

Cron job on host executed payload (lack of monitoring)

Root shell obtained on host

SSH key collection and lateral movement

Impact Assessment
Confidentiality: High - Cluster secrets, application data

Integrity: High - System binaries modified

Availability: Medium - No service disruption

Compliance: Failed - PCI-DSS, SOC2, ISO27001

Root Cause Analysis
Primary Causes
Lack of host access controls: No policies blocking hostNetwork/hostPID

Insecure defaults: Workloads deployed without securityContext

Missing admission control: No validation of pod specifications

Insufficient monitoring: No alerts for privilege escalation attempts

Legacy workloads: Old applications with insecure configurations

Contributing Factors
Development teams bypassing security for convenience

Lack of security scanning in CI/CD pipeline

Insufficient security training for developers

No automated compliance checking

Missing exception management process

Evidence Collected
Container logs: Show enumeration commands

Host logs: Show binary execution timestamps

Network logs: Show lateral movement patterns

Kubernetes audit logs: Show pod creation events

Security tool alerts: Retroactively identified indicators

Immediate Actions Taken
Isolated compromised nodes

Rotated all credentials and certificates

Removed malicious binaries

Enhanced logging and monitoring

Started security policy implementation

Recommendations
Short-term (24 hours)
Implement host access blocking policies

Audit all workloads for host access configurations

Enable Pod Security Admission in enforcing mode

Deploy runtime security monitoring

Medium-term (7 days)
Implement admission webhooks for security validation

Deploy vulnerability scanning for containers

Enhance security monitoring and alerting

Conduct security training for development teams

Long-term (30 days)
Implement zero-trust network policies

Deploy behavioral anomaly detection

Establish security compliance automation

Regular security assessment and penetration testing

Lessons Learned
Defense in depth: Multiple security controls needed

Default deny: Start with restrictive policies, allow exceptions

Continuous monitoring: Real-time detection is critical

Automated enforcement: Manual reviews insufficient

Security culture: Technical controls need organizational support

Compliance Impact
PCI-DSS: Requirement 2.2 violated - insecure configurations

SOC2: CC6.1 violated - logical access controls

ISO27001: A.12.6 violated - technical vulnerability management

HIPAA: 164.308(a)(5) violated - security management process

Attachments
Full forensic analysis report

Compromised artifact samples

Timeline visualization

Policy violation statistics