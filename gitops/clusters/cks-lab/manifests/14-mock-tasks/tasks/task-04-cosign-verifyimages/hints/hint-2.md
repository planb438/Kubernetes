# Hint 2: Cosign Signature Verification Details (Cost: 3 points)

## Cosign Verification Process
1. **Image must be signed** with Cosign private key
2. **Signature stored** in registry as separate artifact
3. **Public key used** to verify signature
4. **Digest ensures** image hasn't been modified

## SBOM Attestation
```yaml
attestations:
- predicateType: "https://spdx.dev/Document"
  conditions:
  - key: "{{ predicate.sbom.creator }}"
    operator: Equals
    value: "company-ci"
Emergency Patch Configuration
yaml
# Rule for emergency patches
- name: allow-emergency-patches
  match:
    namespaces:
    - kube-system
  preconditions:
    any:
    - key: "{{ request.object.metadata.annotations.\"emergency-patch\" }}"
      operator: Equals
      value: "true"
  validate:
    message: "Emergency patch allowed"
Registry Configuration
yaml
# ConfigMap for registry settings
apiVersion: v1
kind: ConfigMap
metadata:
  name: image-registry-config
  namespace: kyverno
data:
  registries.yaml: |
    registries:
      - name: ghcr.io
        insecure: false
Common Issues
Missing public key - Ensure key is properly formatted

Registry access - Kyverno needs pull access to verify

Image pattern matching - Use correct wildcards

Namespace exclusions - Use namespaces: ["!kube-system"]

Verification Command
bash
# Manual Cosign verification (outside Kyverno)
cosign verify --key cosign.pub ghcr.io/company/image:tag