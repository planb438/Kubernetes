markdown
# CKS Exercise 08: Supply Chain Security with Cosign

## Learning Objectives:
- Implement image signing and verification with Cosign
- Configure Kyverno for admission control
- Set up keyless signing with Sigstore
- Verify SBOMs and SLSA attestations

## Scenario:
Your organization needs to ensure container images are from trusted
sources and haven't been tampered with during the supply chain.

## Tasks:

### Task 1: Deploy Verification Infrastructure
1. Install Kyverno with Cosign support
2. Configure image verification policies
3. Set up public key management

### Task 2: Test Verification Policies
1. Deploy signed images (should be allowed)
2. Deploy unsigned images (should be rejected)
3. Deploy tampered images (should be rejected)
4. Verify error messages and logs

### Task 3: Implement Keyless Signing
1. Set up GitHub Actions workflow for keyless signing
2. Configure OIDC authentication
3. Test end-to-end signing and verification

### Task 4: Advanced Verification
1. Add SLSA provenance verification
2. Require SBOM attestations
3. Implement policy exemptions for specific namespaces
4. Set up alerting for verification failures

## Success Criteria:
- [ ] Kyverno policies deployed via GitOps
- [ ] Signed images allowed, unsigned rejected
- [ ] Keyless signing configured in CI/CD
- [ ] SBOM and provenance verification working
- [ ] Monitoring and alerting configured

## Production Checklist:
- [ ] All production images are signed
- [ ] Admission control prevents unsigned images
- [ ] Key rotation process documented
- [ ] Emergency bypass process (for outages)
- [ ] Regular policy audits
- [ ] Integration with vulnerability scanning
🚀 DEPLOYMENT WORKFLOW:
In ArgoCD UI:
text
Application 1: kyverno-cosign
Repo: https://kyverno.github.io/kyverno/
Chart: kyverno
Namespace: kyverno

Application 2: cosign-verification-lab
Path: gitops/clusters/cks-lab/manifests/08-cosign-verify-public
Namespace: supply-chain-lab
Testing Commands:
bash
# Test image signing verification
cosign verify --key https://fulcio.sigstore.dev/ghcr.pub ghcr.io/sigstore/cosign:v2.2.3

# Check Kyverno logs
kubectl logs -n kyverno deployment/kyverno

# Test policy enforcement
kubectl apply -f unsigned-deployment.yaml  # Should fail
kubectl apply -f verified-deployment.yaml  # Should succeed
💡 KEY SUPPLY CHAIN SECURITY CONCEPTS:
Image Signing: Digital signatures prove image authenticity

Keyless Signing: OIDC-based, no key management needed

Transparency Logs: Rekor provides immutable audit trail

Attestations: SBOMs, SLSA provenance, vulnerability reports

Policy Enforcement: Admission control prevents untrusted images

🔧 SIGSTORE COMPONENTS:
Component	Purpose	Use Case
Cosign	Sign/verify images	Image authenticity
Fulcio	Root CA for keyless	OIDC certificate authority
Rekor	Transparency log	Immutable signature log
CTLog	Certificate transparency	Certificate logging
Want me to:

Add TUF (The Update Framework) integration?

Create emergency bypass procedures for outages?

Add compliance reporting (FDA, NIST, etc.)?

Create multi-cluster sync for signed images?

This transforms your Cosign lab into a complete supply chain security framework for production!

