# Task 6: SBOM Generation and Vulnerability Scanning

## Overview
This task tests your ability to implement Software Bill of Materials (SBOM) generation and vulnerability scanning for container images, a critical component of software supply chain security.

## Learning Objectives
- Understand SBOM concepts and regulatory requirements
- Implement automated SBOM generation pipelines
- Perform vulnerability scanning with multiple tools
- Integrate scanning into CI/CD and admission control
- Store and manage SBOMs for audit and compliance
- Generate compliance reports for regulatory frameworks

## Prerequisites
- Basic understanding of container images and dependencies
- Familiarity with JSON and YAML formats
- Knowledge of vulnerability management concepts
- Understanding of Kubernetes CronJobs and ConfigMaps

## Key Concepts

### 1. Software Bill of Materials (SBOM)
An inventory of all components in a software product, including dependencies, licenses, and provenance information.

### 2. Vulnerability Scanning
The process of identifying security vulnerabilities in software components using databases of known vulnerabilities.

### 3. Supply Chain Security
Protecting the integrity of software throughout its lifecycle, from development to deployment.

### 4. Compliance Frameworks
Regulatory requirements including NIST SSDF, CISA SBOM, and Executive Order 14028.

## Task Structure
- `instructions.md`: Complete scenario with regulatory requirements
- `provided-files/`: Application source code, compliance frameworks, vulnerability database
- `solution/`: Complete implementation with automation pipeline
- `test/`: Verification, compliance checking, and integration testing
- `hints/`: Guided assistance (with point cost)

## Time Management
- Recommended time: 25 minutes
- Points: 28/100
- Hint cost: 3 points each

## Success Criteria
- Automated SBOM generation for all production images
- Vulnerability scanning integrated into deployment pipeline
- SBOMs stored securely and retrievable
- Compliance with regulatory frameworks
- Real-time blocking of critical vulnerabilities
- Comprehensive reporting and alerting

## Testing Strategy
1. **SBOM generation**: Verify all formats (SPDX, CycloneDX, JSON)
2. **Vulnerability scanning**: Test with known vulnerable images
3. **Integration**: Verify admission control blocking
4. **Storage**: Check SBOM storage and retrieval
5. **Compliance**: Generate and validate compliance reports

## Related CKS Domains
- Supply Chain Security
- Cluster Hardening
- System Hardening
- Monitoring, Logging and Runtime Security

## Real-World Application
- Regulatory compliance (NIST, CISA, Executive Order)
- Vulnerability management programs
- Software supply chain transparency
- Audit and compliance reporting
- Security incident response

## Tools Used
- **Syft**: SBOM generation from Anchore
- **Grype**: Vulnerability scanning from Anchore
- **Trivy**: Comprehensive security scanner from Aqua Security
- **Kyverno**: Policy-based vulnerability checking
- **Kubernetes**: Automation and storage

## Common Pitfalls to Avoid
1. Not scanning all image layers
2. Missing dependency relationships in SBOM
3. Inadequate vulnerability database updates
4. Poor performance with large images
5. Insecure storage of SBOM data
6. Missing compliance reporting
7. No integration with admission control

## References
- SPDX Specification: https://spdx.dev/specifications/
- CycloneDX Specification: https://cyclonedx.org/
- NIST SSDF: https://csrc.nist.gov/publications/detail/sp/800-218/final
- CISA SBOM: https://www.cisa.gov/sbom
- Executive Order 14028: https://www.whitehouse.gov/briefing-room/presidential-actions/2021/05/12/executive-order-on-improving-the-nations-cybersecurity/
File 7: ArgoCD Application for Task 6
clusters/cks-lab/applications/14-task-06-sbom-scan.yaml

yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: 14-task-06-sbom-scan
  namespace: argocd
  annotations:
    argocd.argoproj.io/sync-wave: "5"
    cks-task: "06"
spec:
  project: default
  source:
    repoURL: https://github.com/planb438/Kubernetes.git
    targetRevision: HEAD
    path: gitops/clusters/cks-lab/manifests/14-mock-tasks/task-06-sbom-scan/provided-files
    directory:
      recurse: true
  destination:
    server: https://kubernetes.default.svc
    namespace: sbom-system
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
    syncOptions:
      - CreateNamespace=true
  info:
    - name: Description
      value: "Task 6 - SBOM Generation and Vulnerability Scanning"
    - name: Points
      value: "28"
    - name: Time Limit
      value: "25 minutes"
    - name: CKS Domain
      value: "Supply Chain Security"
    - name: Key Skills
      value: "SBOM Generation, Vulnerability Scanning, Compliance Reporting"
    - name: Tools Required
      value: "Syft, Grype, Trivy, Kyverno"