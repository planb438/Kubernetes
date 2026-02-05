# Mock CKS Exam - Task 6: SBOM Generation and Vulnerability Scanning

## Task Description
Following new regulatory requirements for software supply chain transparency, you must implement an SBOM (Software Bill of Materials) generation and vulnerability scanning pipeline for all production container images.

## Requirements
1. **Create an automated pipeline** that:
   - Generates SBOMs for all container images in the `production` namespace
   - Scans images for vulnerabilities using multiple scanners
   - Stores SBOMs and scan results for audit purposes
   - Creates alerts for critical vulnerabilities
   - Integrates with the CI/CD process

2. **Implement SBOM generation** using:
   - Syft for comprehensive package detection
   - Output in both SPDX and CycloneDX formats
   - Attestation signing with Cosign
   - Storage in a secure repository

3. **Perform vulnerability scanning** with:
   - Grype for vulnerability matching
   - Trivy for comprehensive scanning
   - Integration with Kubernetes admission control
   - Severity-based reporting and blocking

4. **Create compliance reports** for:
   - NIST Software Supply Chain Security Framework
   - CISA SBOM requirements
   - Company security policy v4.0

## Provided Resources
- Application source code in `provided-files/application-source/`
- Existing container images in production namespace
- Vulnerability database with known CVEs
- Compliance framework definitions

## Security Requirements
1. **SBOM must include**: All dependencies, licenses, authors, and provenance
2. **Vulnerability scanning**: Must check against multiple databases
3. **Critical vulnerabilities**: Must block deployment automatically
4. **SBOM storage**: Must be tamper-evident and accessible for audits
5. **Scan frequency**: Daily for production, on-push for development

## Technical Requirements
1. **SBOM formats**: SPDX 2.3 and CycloneDX 1.5
2. **Vulnerability thresholds**: 
   - Block: CRITICAL severity
   - Warn: HIGH severity
   - Info: MEDIUM and LOW severity
3. **Storage**: ConfigMap for current, S3-compatible for historical
4. **Integration**: Must work with existing ArgoCD deployment pipeline

## Constraints
- Time limit: 25 minutes
- Points: 28/100
- Must use open-source tools (Syft, Grype, Trivy)
- SBOMs must be machine-readable (JSON format)
- Historical data must be preserved for 7 years
- Real-time alerts for new critical vulnerabilities

## Success Criteria
- SBOM generated for all production images
- Vulnerability scan completes with no blocking issues
- SBOMs stored securely and retrievable
- Compliance reports generated
- Integration with admission controller working
- Alerts configured for critical findings

## Available Hints (cost: 3 points each)
1. Hint 1: SBOM generation tools and formats
2. Hint 2: Vulnerability scanning integration