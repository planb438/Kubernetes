# Hint 1: Kyverno verifyImages Policy Structure (Cost: 3 points)

## Basic Structure
```yaml
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: verify-images
spec:
  validationFailureAction: Enforce
  rules:
  - name: verify-signatures
    match:
      resources:
        kinds:
        - Pod
        - Deployment
    verifyImages:
    - imageReferences:
      - "ghcr.io/company/*"
      attestors:
      - entries:
        - keys:
            publicKeys: |-
              -----BEGIN PUBLIC KEY-----
              YOUR_PUBLIC_KEY
              -----END PUBLIC KEY-----




Key Fields Explained
imageReferences: Pattern matching for images to verify

attestors: Who signed the image (entries with keys)

mutateDigest: If true, mutates image reference to use digest

required: If true, signature is mandatory

verifyDigest: If true, verifies the image digest

Public Key Configuration
yaml
keys:
  publicKeys: |-
    -----BEGIN PUBLIC KEY-----
    MFkwEwYHKoZIzj0CAQYIKoZIzj0DAQcDQgAE...
    -----END PUBLIC KEY-----
Testing Commands
bash
# Check if Kyverno is installed
kubectl get pods -n kyverno

# Test policy application
kubectl apply -f test-pod.yaml --dry-run=server

# View policy violations
kubectl get policyreport -A