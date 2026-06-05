# Mock CKS Exam - Task 4: Supply Chain Security with Cosign

## Task Description
Following a supply chain attack where malicious images were deployed to production, you must implement image signature verification to prevent unauthorized container images from running in the cluster.

## Requirements
1. **Create a Kyverno ClusterPolicy** that:
   - Verifies Cosign signatures for ALL images from `ghcr.io/company/production/*`
   - Uses the provided public key for verification
   - Enforces SBOM attestation for production images
   - Allows unsigned images ONLY in `kube-system` namespace with `emergency-patch: "true"` annotation
   - Blocks deployment if signature verification fails

2. **Configure image registry** to allow only signed images
3. **Test the policy** with:
   - A signed test image (should deploy)
   - An unsigned test image (should be blocked)
   - An emergency patch in kube-system (should deploy)

4. **Create verification mechanism** to confirm policy works

## Provided Resources
- Public key: `provided-files/cosign-pubkey.pub`
- Test images:
  - `ghcr.io/company/production/signed-app:v1.0.0` (signed)
  - `ghcr.io/company/production/unsigned-app:latest` (unsigned)
- Emergency patch image: `nginx:1.25` (for kube-system testing)

## Security Requirements
1. **Production images must be signed** and have SBOM attestation
2. **Signature verification must use SHA256** digests
3. **Failed verification must block deployment** (not just warn)
4. **Emergency patches** must be explicitly annotated
5. **All other namespaces** must enforce signatures

## Constraints
- Time limit: 20 minutes
- Points: 25/100
- Must use Kyverno (already installed in cluster)
- Policy must be cluster-wide
- Include clear error messages
- Test both positive and negative cases

## Success Criteria
- Signed image deploys successfully in default namespace
- Unsigned image is blocked with clear error message
- Emergency patch in kube-system deploys with annotation
- Policy logs verification attempts
- SBOM attestation is verified for production images

## Available Hints (cost: 3 points each)
1. Hint 1: Review Kyverno verifyImages policy structure
2. Hint 2: Cosign signature verification configuration