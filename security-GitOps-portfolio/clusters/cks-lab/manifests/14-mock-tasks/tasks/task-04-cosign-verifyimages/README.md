task-04-cosign-verifyimages/
├── instructions.md
├── provided-files/
│   ├── cosign-pubkey.pub
│   ├── signed-image-list.yaml
│   ├── existing-workloads.yaml
│   ├── test-images/
│   │   ├── Dockerfile.signed
│   │   ├── Dockerfile.unsigned
│   │   ├── app.py
│   │   └── requirements.txt
│   └── emergency-patch-exemption.md
├── solution/
│   ├── kyverno-policy.yaml
│   ├── image-registry-config.yaml
│   ├── signature-verification.sh
│   ├── create-test-images.sh
│   └── policy-explanation.md
├── test/
│   ├── verification-job.yaml
│   ├── test-images.yaml
│   ├── compliance-check.yaml
│   └── expected-results.yaml
├── hints/
│   ├── hint-1.md
│   └── hint-2.md
└── README.md

# Task 4: Cosign Image Verification

## Overview
This task tests your ability to implement supply chain security using Cosign signatures and Kyverno policies to verify container images before they run in the cluster.

## Learning Objectives
- Understand container image signing with Cosign
- Implement Kyverno policies for image verification
- Configure emergency exemptions for critical patches
- Verify SBOM (Software Bill of Materials) attestations
- Test supply chain security controls

## Prerequisites
- Kyverno installed in the cluster
- Basic understanding of public key cryptography
- Familiarity with container registries
- Understanding of Kubernetes admission controllers

## Key Concepts
1. **Cosign Signatures**: Cryptographic verification of container images
2. **SBOM Attestations**: Software bill of materials for transparency
3. **Kyverno verifyImages**: Policy rule for image verification
4. **Emergency Exemptions**: Controlled exceptions for critical patches
5. **Registry Configuration**: Secure access to container registries

## Task Structure
- `instructions.md`: Complete scenario and requirements
- `provided-files/`: Public key, test images, existing workloads
- `solution/`: Complete policy implementation
- `test/`: Automated verification and scoring
- `hints/`: Guided assistance (with point cost)

## Time Management
- Recommended time: 20 minutes
- Points: 25/100
- Hint cost: 3 points each

## Success Criteria
- Production images require valid signatures
- Unsigned images are blocked with clear errors
- Emergency patches allowed with proper annotation
- SBOM attestation verified for production images
- Policy logs all verification attempts

## Testing Strategy
1. Test signed image deployment (should succeed)
2. Test unsigned image deployment (should fail)
3. Test emergency patch with annotation (should succeed)
4. Test emergency patch without annotation (should fail)
5. Verify error messages are clear and actionable

## Related CKS Domains
- Supply Chain Security
- Cluster Hardening
- System Hardening
- Policy Enforcement

## Real-World Application
- Prevent deployment of malicious images
- Ensure software provenance
- Compliance with software supply chain regulations
- Emergency patch management process
File 7: ArgoCD Application for Task 4
clusters/cks-lab/applications/14-task-04-cosign.yaml

yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: 14-task-04-cosign
  namespace: argocd
  annotations:
    argocd.argoproj.io/sync-wave: "3"
    cks-task: "04"
spec:
  project: default
  source:
    repoURL: https://github.com/planb438/Kubernetes.git
    targetRevision: HEAD
    path: gitops/clusters/cks-lab/manifests/14-mock-tasks/task-04-cosign-verifyimages/provided-files
    directory:
      recurse: true
  destination:
    server: https://kubernetes.default.svc
    namespace: mock-exam-system
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
    syncOptions:
      - CreateNamespace=true
  info:
    - name: Description
      value: "Task 4 - Cosign Image Verification for Supply Chain Security"
    - name: Points
      value: "25"
    - name: Time Limit
      value: "20 minutes"
    - name: CKS Domain
      value: "Supply Chain Security"
    - name: Prerequisites
      value: "Kyverno must be installed in cluster"
