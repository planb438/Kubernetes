# Hint 2: Vulnerability Scanning Integration (Cost: 3 points)

## Vulnerability Scanning Pipeline

### Multi-Tool Scanning Strategy
```bash
# Use Grype as primary scanner
grype <image> -o json > grype-results.json

# Use Trivy for validation
trivy image <image> --severity CRITICAL,HIGH -f json > trivy-results.json

# Compare results
jq '.matches[] | select(.vulnerability.severity == "Critical")' grype-results.json
Severity-Based Actions
yaml
# Kyverno policy for vulnerability checking
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: check-vulnerabilities
spec:
  rules:
  - name: block-critical-vulns
    match:
      resources:
        kinds: [Pod, Deployment]
    validate:
      message: "Image contains critical vulnerabilities"
      deny:
        conditions:
          any:
          - key: "{{ scanResults.criticalCount }}"
            operator: GreaterThan
            value: 0
Integration with CI/CD
Pre-deployment Scanning
yaml
# GitLab CI example
sbom-scan:
  stage: test
  image: anchore/syft:latest
  script:
    - syft $CI_REGISTRY_IMAGE:$CI_COMMIT_SHA -o spdx-json > sbom.json
    - grype $CI_REGISTRY_IMAGE:$CI_COMMIT_SHA -o json > vulnerabilities.json
  artifacts:
    paths:
      - sbom.json
      - vulnerabilities.json
Admission Control Webhook
yaml
apiVersion: admissionregistration.k8s.io/v1
kind: ValidatingWebhookConfiguration
metadata:
  name: vulnerability-scanner
webhooks:
- name: scanner.example.com
  rules:
  - operations: ["CREATE"]
    apiGroups: [""]
    apiVersions: ["v1"]
    resources: ["pods"]
  clientConfig:
    service:
      name: vulnerability-scanner
      namespace: default
      path: "/validate"
Storage and Retention
SBOM Storage Strategies
yaml
# ConfigMap for current SBOMs
apiVersion: v1
kind: ConfigMap
metadata:
  name: sbom-current
  namespace: sbom-system
data:
  sbom.json: |
    { "SPDXID": "..." }

# Persistent storage for historical
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: sbom-storage
  namespace: sbom-system
spec:
  accessModes:
    - ReadWriteMany
  resources:
    requests:
      storage: 10Gi
Retention Policy Implementation
bash
#!/bin/bash
# Cleanup old SBOMs
RETENTION_DAYS=90
CURRENT_DATE=$(date +%s)

kubectl get configmaps -n sbom-system --selector=app=sbom-generator -o json | \
  jq -r '.items[] | select((.metadata.creationTimestamp | fromdate) < (now - ('$RETENTION_DAYS' * 86400))) | .metadata.name' | \
  xargs -r kubectl delete configmap -n sbom-system
Monitoring and Alerting
Vulnerability Dashboard
yaml
# Prometheus metrics for vulnerabilities
apiVersion: apps/v1
kind: Deployment
metadata:
  name: vulnerability-exporter
spec:
  template:
    spec:
      containers:
      - name: exporter
        image: custom/exporter
        args:
        - --metrics-port=9090
        - --scan-interval=24h
Alert Rules
yaml
# Prometheus alert for new critical vulnerabilities
groups:
- name: vulnerabilities
  rules:
  - alert: NewCriticalVulnerability
    expr: increase(vulnerabilities_critical_total[24h]) > 0
    labels:
      severity: critical
    annotations:
      summary: "New critical vulnerability detected"
Compliance Reporting
Automated Compliance Reports
bash
#!/bin/bash
# Generate compliance report
REPORT_DATE=$(date +%Y-%m-%d)

cat > compliance-report-$REPORT_DATE.md << EOF
# SBOM Compliance Report
## Date: $REPORT_DATE

## Summary
- Total images scanned: $(kubectl get pods --all-namespaces -o json | jq '.items[].spec.containers[].image' | sort -u | wc -l)
- Critical vulnerabilities: $(jq '.matches[] | select(.vulnerability.severity == "Critical")' scan-results.json | wc -l)
- Compliance status: COMPLIANT

## Details
$(kubectl get configmaps -n sbom-system -l app=sbom-generator -o json | jq -r '.items[].metadata.name')
EOF
Testing Your Implementation
Test with Vulnerable Image
bash
# Use known vulnerable image for testing
docker pull vulnimage/struts2:2.3.20

# Scan and verify detection
grype vulnimage/struts2:2.3.20 -o json | jq '.matches[] | select(.vulnerability.severity == "Critical")'

# Should detect CVE-2017-5638
Integration Test
bash
# Deploy test pod and verify blocking
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Pod
metadata:
  name: test-vulnerable
spec:
  containers:
  - name: test
    image: vulnimage/struts2:2.3.20
EOF

# Should be blocked by admission controller
Performance Optimization
Parallel Scanning
bash
#!/bin/bash
# Scan multiple images in parallel
IMAGES=("image1" "image2" "image3")

for image in "${IMAGES[@]}"; do
  (syft "$image" -o json > "sbom-$image.json" &
   grype "$image" -o json > "vuln-$image.json") &
done

wait
echo "All scans completed"
Caching Strategy
yaml
# Use persistent volume for vulnerability database
volumeMounts:
- name: grype-db
  mountPath: /tmp/grype-db
volumes:
- name: grype-db
  persistentVolumeClaim:
    claimName: grype-db-pvc
Troubleshooting
Slow scans: Use smaller base images, enable caching

False positives: Update vulnerability database regularly

Network errors: Configure proxy, increase timeouts

Storage issues: Implement cleanup, use object storage

Permission issues: Configure service accounts properly