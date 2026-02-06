# Hint 1: SBOM Generation Tools and Formats (Cost: 3 points)

## SBOM Generation Tools

### Syft (Anchore)
```bash
# Installation
curl -sSfL https://raw.githubusercontent.com/anchore/syft/main/install.sh | sh -s -- -b /usr/local/bin

# Basic usage
syft <image> -o <format>

# Output formats:
# - json: Syft native format
# - spdx-json: SPDX 2.3 JSON
# - cyclonedx-json: CycloneDX 1.5 JSON
# - table: Human-readable table


Grype (Vulnerability Scanner)
bash
# Installation
curl -sSfL https://raw.githubusercontent.com/anchore/grype/main/install.sh | sh -s -- -b /usr/local/bin

# Scan image
grype <image> -o <format>

# Output formats:
# - json: Machine-readable
# - table: Human-readable
# - cyclonedx: CycloneDX format
SBOM Formats
SPDX (Software Package Data Exchange)
json
{
  "SPDXID": "SPDXRef-DOCUMENT",
  "spdxVersion": "SPDX-2.3",
  "name": "Image SBOM",
  "packages": [
    {
      "SPDXID": "SPDXRef-Package-flask",
      "name": "flask",
      "versionInfo": "2.3.3",
      "licenseConcluded": "BSD-3-Clause"
    }
  ]
}
CycloneDX (OWASP Standard)
json
{
  "bomFormat": "CycloneDX",
  "specVersion": "1.5",
  "components": [
    {
      "type": "library",
      "bom-ref": "pkg:pypi/flask@2.3.3",
      "name": "flask",
      "version": "2.3.3"
    }
  ]
}
Kubernetes Integration
CronJob for Regular Scanning
yaml
apiVersion: batch/v1
kind: CronJob
metadata:
  name: sbom-generator
spec:
  schedule: "0 2 * * *"  # Daily at 2 AM
  jobTemplate:
    spec:
      template:
        spec:
          containers:
          - name: sbom-scanner
            image: alpine
            command: ["syft", "image:tag", "-o", "spdx-json"]
Storing SBOMs as ConfigMaps
bash
# Create ConfigMap from SBOM file
kubectl create configmap sbom-results \
  --from-file=sbom.json \
  -n sbom-system

# Retrieve SBOM
kubectl get configmap sbom-results -n sbom-system -o jsonpath='{.data.sbom\.json}'
Compliance Requirements
NIST SSDF Requirements
PO.1: Identify and document software components

PS.3: Generate and archive SBOMs

PW.8: Verify third-party software components

CISA SBOM Minimum Elements
Supplier name

Component name

Version string

Dependency relationship

Timestamp

Testing Commands
bash
# Test Syft installation
syft --version

# Generate test SBOM
syft alpine:latest -o json

# Test Grype installation
grype --version

# Scan for vulnerabilities
grype alpine:latest -o table

# Check installed tools
which syft grype
Common Issues and Solutions
Permission denied: Ensure tool installation directory is in PATH

Image not found: Pull image before scanning

JSON parsing errors: Use jq for validation

Network issues: Configure proxy if behind firewall

Storage full: Implement cleanup policy for old SBOMs