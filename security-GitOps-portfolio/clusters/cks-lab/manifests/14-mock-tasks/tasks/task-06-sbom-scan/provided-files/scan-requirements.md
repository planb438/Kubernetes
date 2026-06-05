# SBOM and Vulnerability Scanning Requirements

## Regulatory Requirements
1. **Executive Order 14028** (US): Requires SBOM for critical software
2. **NIST SP 800-161**: Supply Chain Risk Management Practices
3. **CISA SBOM Elements**: Minimum required SBOM fields
4. **PCI-DSS Requirement 6**: Secure development lifecycle

## SBOM Requirements

### Minimum Data Elements (CISA)
1. **Supplier Name**: Author of the SBOM
2. **Component Name**: Name of the software component
3. **Version String**: Version of the component
4. **Other Unique Identifiers**: CPE, PURL, SWID
5. **Dependency Relationship**: How components relate
6. **Author of SBOM Data**: Who created the SBOM
7. **Timestamp**: When the SBOM was created

### Required Formats
1. **SPDX 2.3**: Industry standard format
2. **CycloneDX 1.5**: OWASP standard format
3. **JSON serialization**: For machine processing
4. **Human-readable summary**: For audit purposes

## Vulnerability Scanning Requirements

### Scanning Tools
1. **Primary**: Grype (Anchore)
2. **Secondary**: Trivy (Aqua Security)
3. **Validation**: Snyk (for comparison)

### Severity Classification
| Severity | CVSS Score | Action Required |
|----------|------------|-----------------|
| CRITICAL | 9.0 - 10.0 | Block deployment, immediate remediation |
| HIGH     | 7.0 - 8.9  | Block deployment, remediate within 7 days |
| MEDIUM   | 4.0 - 6.9  | Warn, remediate within 30 days |
| LOW      | 0.1 - 3.9  | Inform, remediate in next release |
| NONE     | 0.0        | No action required |

### Scanning Frequency
- **Production images**: Daily automated scan
- **New deployments**: Scan on every push
- **Critical applications**: Real-time monitoring
- **Legacy systems**: Weekly comprehensive scan

## Storage and Retention

### SBOM Storage
1. **Primary**: S3-compatible object storage
2. **Secondary**: Kubernetes ConfigMaps (current only)
3. **Backup**: Git repository with version control
4. **Access Control**: RBAC protected, audit logged

### Retention Policy
- **Current SBOMs**: 90 days in ConfigMaps
- **Historical SBOMs**: 7 years in object storage
- **Scan results**: 2 years for audit purposes
- **Vulnerability data**: 5 years for trend analysis

## Integration Requirements

### CI/CD Pipeline
1. **Pre-deployment**: Scan and generate SBOM
2. **Gate check**: Block on critical vulnerabilities
3. **Post-deployment**: Store SBOM and scan results
4. **Notification**: Alert on new vulnerabilities

### Kubernetes Integration
1. **Admission controller**: Validate images before deployment
2. **Operator**: Automated scanning of running workloads
3. **Dashboard**: Visibility into SBOM and vulnerabilities
4. **API access**: Programmatic access to SBOM data

## Compliance Reporting

### Required Reports
1. **Monthly**: Vulnerability status report
2. **Quarterly**: SBOM completeness report
3. **Annual**: Supply chain security assessment
4. **On-demand**: Audit/compliance evidence

### Report Contents
- Total images scanned
- Vulnerabilities by severity
- SBOM coverage percentage
- Remediation progress
- Compliance status

## Exception Handling

### Vulnerability Exceptions
1. **Temporary**: 30-day exception with business justification
2. **Permanent**: Architecture limitation with risk acceptance
3. **False positive**: Vendor-confirmed with evidence

### Process Requirements
1. **Approval**: Security team + application owner
2. **Documentation**: Risk acceptance form
3. **Monitoring**: Regular review of exceptions
4. **Expiration**: Automatic expiration with reminders

## Testing Requirements
1. **SBOM accuracy**: Compare with actual container contents
2. **Vulnerability detection**: Test with known vulnerable images
3. **Performance**: Scan completes within 5 minutes
4. **Integration**: End-to-end pipeline testing