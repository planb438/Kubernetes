Kubernetes/gitops/
├── clusters/
│   └── cks-lab/
│       ├── applications/
│       │   ├── 11-sbom-vuln-setup.yaml
│       │   ├── 11-sbom-generator.yaml
│       │   ├── 11-vuln-scanner.yaml
│       │   └── 11-compliance-checker.yaml
│       └── manifests/
│           └── 11-sbom-vuln-scan/
│               ├── infrastructure/
│               │   ├── sbom-namespaces.yaml
│               │   ├── sbom-service-accounts.yaml
│               │   └── sbom-rbac.yaml
│               ├── tools/
│               │   ├── syft-installer.yaml
│               │   ├── grype-installer.yaml
│               │   ├── trivy-installer.yaml
│               │   └── cosign-installer.yaml
│               ├── pipelines/
│               │   ├── build-scan-push.yaml
│               │   ├── admission-controller.yaml
│               │   ├── image-verification.yaml
│               │   └── policy-enforcement.yaml
│               ├── images/
│               │   ├── demo-images/
│               │   │   ├── vulnerable-app/
│               │   │   │   ├── Dockerfile
│               │   │   │   ├── app.py
│               │   │   │   └── requirements.txt
│               │   │   ├── secure-app/
│               │   │   │   ├── Dockerfile
│               │   │   │   ├── app.py
│               │   │   │   └── requirements.txt
│               │   │   └── multi-stage/
│               │   │       ├── Dockerfile
│               │   │       └── build.sh
│               │   └── base-images/
│               │       ├── alpine-base/
│               │       ├── ubuntu-base/
│               │       └── distroless/
│               ├── scanning/
│               │   ├── sbom-generator-job.yaml
│               │   ├── vulnerability-scanner.yaml
│               │   ├── compliance-check.yaml
│               │   └── scanning-policies.yaml
│               ├── workloads/
│               │   ├── good-workloads/
│               │   │   ├── scanned-deployment.yaml
│               │   │   ├ attested-deployment.yaml
│               │   │   └── sbom-verified-job.yaml
│               │   ├── bad-workloads/
│               │   │   ├── vulnerable-deployment.yaml
│               │   │   ├── unsigned-deployment.yaml
│               │   │   └── critical-vuln-pod.yaml
│               │   └── test-workloads/
│               │       ├── scan-test-pod.yaml
│               │       ├── policy-test-job.yaml
│               │       └── admission-test.yaml
│               ├── policies/
│               │   ├── vulnerability-policies.yaml
│               │   ├── sbom-policies.yaml
│               │   ├── allowed-images.yaml
│               │   ├── severity-thresholds.yaml
│               │   └── exception-policies.yaml
│               ├── monitoring/
│               │   ├── vulnerability-dashboard.yaml
│               │   ├── sbom-tracker.yaml
│               │   ├── compliance-report.yaml
│               │   └── alert-config.yaml
│               ├── testing/
│               │   ├── scan-validation.yaml
│               │   ├── policy-enforcement-test.yaml
│               │   ├── admission-testing.yaml
│               │   └── end-to-end-test.yaml
│               └── README-exercise.md
├── policies/
│   └── sbom-vuln/
│       ├── cis-image-requirements.yaml
│       ├── nist-supply-chain.yaml
│       ├── pci-dss-image-scanning.yaml
│       └── slsa-requirements.yaml
└── tools/
    └── scanning-tools/
        ├── scan-automation.yaml
        ├── sbom-db-sync.yaml
        └── vuln-trend-analyzer.yaml

markdown
# CKS Lab 11 - SBOM and Vulnerability Scanning

## Lab Objectives
1. Understand Software Bill of Materials (SBOM) and its importance
2. Generate SBOMs for container images using Syft
3. Perform vulnerability scanning using Grype and Trivy
4. Implement image admission control for security validation
5. Create security policies for vulnerability management
6. Integrate scanning into CI/CD pipelines
7. Understand compliance requirements for software supply chain

## Prerequisites
- Kubernetes cluster
- Container registry access (Docker Hub, etc.)
- kubectl configured
- ArgoCD installed

## Lab Setup

### Part 1: Deploy via GitOps
```bash
# Apply all SBOM and vulnerability scanning applications
kubectl apply -f clusters/cks-lab/applications/11-sbom-vuln-setup.yaml
kubectl apply -f clusters/cks-lab/applications/11-sbom-generator.yaml
kubectl apply -f clusters/cks-lab/applications/11-vuln-scanner.yaml
kubectl apply -f clusters/cks-lab/applications/11-compliance-checker.yaml

# Monitor deployment
argocd app list | grep 11-sbom
Part 2: Verify Installation
bash
# Check scanning tools are deployed
kubectl get pods -n sbom-system

# Check for SBOM ConfigMap
kubectl get configmap -n sbom-system sbom-repository

# Run test scan job
kubectl create -f clusters/cks-lab/manifests/11-sbom-vuln-scan/scanning/vulnerability-scanner.yaml
Exercises
Exercise 1: SBOM Generation
Generate SBOM for existing container images in the cluster

Compare different SBOM formats (SPDX, CycloneDX)

Store and version SBOMs for audit purposes

Query SBOMs for specific packages or licenses

Exercise 2: Vulnerability Scanning
Scan container images for known vulnerabilities

Configure severity thresholds and filtering

Integrate scanning into deployment pipelines

Create vulnerability reports and dashboards

Exercise 3: Admission Control
Implement webhook for image validation

Block deployment of vulnerable images

Create exception policies for approved vulnerabilities

Test admission control with both good and bad images

Exercise 4: Policy Creation
Create policies for vulnerability management

Implement compliance requirements (PCI-DSS, NIST)

Configure automated remediation workflows

Set up alerts for critical vulnerabilities

Exercise 5: CI/CD Integration
Integrate scanning into build pipelines

Implement break-the-build on critical vulnerabilities

Create SBOM attestation and signing

Set up vulnerability trend analysis

Hands-on Activities
Activity 1: Generate SBOM for Demo Image
bash
# Build a demo image
docker build -t demo-image:1.0 -f clusters/cks-lab/manifests/11-sbom-vuln-scan/images/demo-images/vulnerable-app/Dockerfile .

# Generate SBOM
syft demo-image:1.0 -o json > sbom.json
syft demo-image:1.0 -o spdx-json > sbom.spdx.json

# Examine SBOM
cat sbom.json | jq '.artifacts[] | select(.name == "flask")'
Activity 2: Scan for Vulnerabilities
bash
# Scan with Grype
grype demo-image:1.0 --output json > vulnerabilities.json

# Scan with Trivy
trivy image demo-image:1.0 --severity HIGH,CRITICAL --format json > trivy-results.json

# Analyze results
cat vulnerabilities.json | jq '.matches[] | select(.vulnerability.severity == "Critical")'
Activity 3: Test Admission Control
bash
# Try to deploy a vulnerable image
kubectl apply -f clusters/cks-lab/manifests/11-sbom-vuln-scan/workloads/bad-workloads/vulnerable-deployment.yaml

# Check if admission controller blocks it
kubectl get events -n sbom-test | grep -i "admission"

# Deploy a secure image
kubectl apply -f clusters/cks-lab/manifests/11-sbom-vuln-scan/workloads/good-workloads/scanned-deployment.yaml
Verification
bash
# Verify SBOM generation is working
kubectl logs -n sbom-system -l job-name=sbom-generator --tail=20

# Check vulnerability scans
kubectl logs -n sbom-system -l job-name=vulnerability-scanner --tail=50

# Test admission webhook
curl -k https://image-admission-controller.sbom-system.svc.cluster.local:8443/healthz

# View SBOM repository
kubectl get configmap -n sbom-system sbom-repository -o jsonpath='{.data}' | jq keys
Cleanup
bash
# Delete ArgoCD applications
kubectl delete -f clusters/cks-lab/applications/11-sbom-*.yaml

# Clean up namespaces
kubectl delete namespace sbom-system sbom-test sbom-monitoring

# Remove demo images
docker rmi demo-image:1.0 vulnerable-demo:latest secure-demo:latest
Learning Points
SBOMs are essential for software transparency and security

Regular vulnerability scanning helps identify and remediate risks

Admission control prevents vulnerable images from being deployed

Compliance frameworks require documented software supply chain security

Automated scanning integrated into CI/CD improves security posture

Additional Resources
SPDX Specification

CycloneDX Specification

Syft Documentation

Grype Documentation

Trivy Documentation

NIST Software Supply Chain Security

text

## **Deployment Commands:**

```bash
# 1. Commit and push the new lab structure
cd Kubernetes
git add .
git commit -m "Add CKS Lab 11 - SBOM and Vulnerability Scanning"
git push origin main

# 2. Deploy via ArgoCD
kubectl apply -f gitops/clusters/cks-lab/applications/11-sbom-vuln-setup.yaml
kubectl apply -f gitops/clusters/cks-lab/applications/11-sbom-generator.yaml
kubectl apply -f gitops/clusters/cks-lab/applications/11-vuln-scanner.yaml
kubectl apply -f gitops/clusters/cks-lab/applications/11-compliance-checker.yaml

# 3. Monitor deployment
argocd app sync 11-sbom-vuln-setup
argocd app sync 11-sbom-generator
argocd app sync 11-vuln-scanner
argocd app sync 11-compliance-checker

# 4. Verify installation
kubectl get pods -n sbom-system
kubectl get configmap -n sbom-system

# 5. Run manual tests
# Build and scan demo image
cd gitops/clusters/cks-lab/manifests/11-sbom-vuln-scan/images/demo-images/vulnerable-app
docker build -t vulnerable-demo:1.0 .
syft vulnerable-demo:1.0 -o json
grype vulnerable-demo:1.0

# 6. Test admission control
kubectl apply -f gitops/clusters/cks-lab/manifests/11-sbom-vuln-scan/workloads/test-workloads/scan-test-pod.yaml
This follows your exact pattern with:

Multiple ArgoCD applications for different components

Containerized tool installation

Comprehensive demo images with vulnerabilities

Automated scanning jobs

Admission control implementation

Security policies and compliance requirements

Complete documentation and exercises

The structure maintains consistency with your other labs while providing a complete SBOM and vulnerability scanning implementation.

