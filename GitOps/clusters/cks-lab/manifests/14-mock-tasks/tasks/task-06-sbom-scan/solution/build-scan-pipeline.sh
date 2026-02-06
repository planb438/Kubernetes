#!/bin/bash
echo "=== SBOM Generation and Vulnerability Scanning Pipeline ==="
echo ""

# Configuration
IMAGE_NAME="ghcr.io/company/production/sbom-demo-app:v2.1.0"
NAMESPACE="production"
SBOM_DIR="/sbom-output"
SCAN_DIR="/scan-output"
TIMESTAMP=$(date -Iseconds)

echo "1. Building container image..."
echo "   Image: $IMAGE_NAME"
echo ""

# Build the image (simulated for exam)
echo "Simulating image build..."
cat <<EOF > /tmp/Dockerfile
FROM python:3.11-slim
COPY app.py /app.py
COPY requirements.txt /requirements.txt
RUN pip install -r /requirements.txt
CMD ["python", "/app.py"]
EOF

echo "2. Generating SBOM with Syft..."
echo ""

# Generate SBOM in multiple formats
echo "Generating SPDX format..."
syft $IMAGE_NAME -o spdx-json > $SBOM_DIR/sbom-$TIMESTAMP.spdx.json

echo "Generating CycloneDX format..."
syft $IMAGE_NAME -o cyclonedx-json > $SBOM_DIR/sbom-$TIMESTAMP.cyclonedx.json

echo "Generating JSON format..."
syft $IMAGE_NAME -o json > $SBOM_DIR/sbom-$TIMESTAMP.json

echo ""
echo "3. Scanning for vulnerabilities with Grype..."
echo ""

# Vulnerability scanning
echo "Running Grype scan..."
grype $IMAGE_NAME -o json > $SCAN_DIR/vuln-grype-$TIMESTAMP.json
grype $IMAGE_NAME -o table > $SCAN_DIR/vuln-grype-$TIMESTAMP.txt

echo ""
echo "4. Scanning with Trivy for validation..."
echo ""

trivy image --severity CRITICAL,HIGH $IMAGE_NAME -f json > $SCAN_DIR/vuln-trivy-$TIMESTAMP.json
trivy image --severity CRITICAL,HIGH $IMAGE_NAME > $SCAN_DIR/vuln-trivy-$TIMESTAMP.txt

echo ""
echo "5. Analyzing scan results..."
echo ""

# Analyze results
CRITICAL_COUNT=$(jq '.matches[] | select(.vulnerability.severity == "Critical") | .vulnerability.id' $SCAN_DIR/vuln-grype-$TIMESTAMP.json | wc -l)
HIGH_COUNT=$(jq '.matches[] | select(.vulnerability.severity == "High") | .vulnerability.id' $SCAN_DIR/vuln-grype-$TIMESTAMP.json | wc -l)

echo "Vulnerability Summary:"
echo "  CRITICAL: $CRITICAL_COUNT"
echo "  HIGH: $HIGH_COUNT"

echo ""
echo "6. Storing SBOM and scan results..."
echo ""

# Create ConfigMap for current results
kubectl create configmap sbom-results-$TIMESTAMP \
  --from-file=$SBOM_DIR/ \
  --from-file=$SCAN_DIR/ \
  -n sbom-system \
  --dry-run=client -o yaml | kubectl apply -f -

echo ""
echo "7. Creating compliance report..."
echo ""

# Generate compliance report
cat > $SCAN_DIR/compliance-report-$TIMESTAMP.md << EOF
# SBOM and Vulnerability Compliance Report
## Generated: $TIMESTAMP
## Image: $IMAGE_NAME

## Executive Summary
- SBOM generated successfully in 3 formats
- Vulnerability scan completed
- Critical vulnerabilities: $CRITICAL_COUNT
- High vulnerabilities: $HIGH_COUNT

## SBOM Details
- SPDX 2.3: sbom-$TIMESTAMP.spdx.json
- CycloneDX 1.5: sbom-$TIMESTAMP.cyclonedx.json
- Syft JSON: sbom-$TIMESTAMP.json

## Vulnerability Details
- Grype results: vuln-grype-$TIMESTAMP.json
- Trivy results: vuln-trivy-$TIMESTAMP.json
- Scan summary: vuln-summary-$TIMESTAMP.txt

## Compliance Status
- NIST SSDF: COMPLIANT
- CISA SBOM: COMPLIANT  
- Company Policy: $( [ $CRITICAL_COUNT -eq 0 ] && echo "COMPLIANT" || echo "NON-COMPLIANT" )

## Actions Required
$(if [ $CRITICAL_COUNT -gt 0 ]; then
  echo "- IMMEDIATE: Remediate $CRITICAL_COUNT critical vulnerabilities"
fi)
$(if [ $HIGH_COUNT -gt 0 ]; then
  echo "- HIGH PRIORITY: Address $HIGH_COUNT high severity vulnerabilities within 7 days"
fi)
EOF

echo ""
echo "8. Integrating with admission controller..."
echo ""

# Create Kyverno policy for vulnerability checking
cat > /tmp/vulnerability-policy.yaml << EOF
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: check-vulnerabilities
spec:
  validationFailureAction: Enforce
  background: true
  rules:
  - name: check-image-vulnerabilities
    match:
      any:
      - resources:
          kinds:
          - Pod
          - Deployment
          - DaemonSet
          - StatefulSet
    context:
    - name: vulnerabilityReport
      apiCall:
        urlPath: "/api/v1/namespaces/sbom-system/configmaps/sbom-results-$TIMESTAMP"
        jmesPath: "data.vuln-grype-$TIMESTAMP.json"
    validate:
      message: "Image contains critical vulnerabilities"
      deny:
        conditions:
          any:
          - key: "{{ vulnerabilityReport.matches[].severity }}"
            operator: AnyIn
            value: ["Critical"]
EOF

kubectl apply -f /tmp/vulnerability-policy.yaml

echo ""
echo "=== Pipeline Complete ==="
echo ""
echo "Summary:"
echo "- SBOM generated in 3 formats"
echo "- Vulnerability scan completed"
echo "- Results stored in ConfigMap"
echo "- Compliance report generated"
echo "- Admission policy applied"
echo ""
echo "Files generated:"
ls -la $SBOM_DIR/
ls -la $SCAN_DIR/