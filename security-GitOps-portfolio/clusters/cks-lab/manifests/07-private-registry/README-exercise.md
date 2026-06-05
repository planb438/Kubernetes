Kubernetes/gitops/
├── clusters/
│   └── cks-lab/
│       ├── applications/
│       │   ├── 07-private-registry.yaml
│       │   ├── 07-image-pull-secrets.yaml
│       │   └── 07-registry-scanning.yaml
│       └── manifests/
│           └── 07-private-registry/
│               ├── registries/
│               │   ├── docker-hub.yaml
│               │   ├── ghcr.yaml
│               │   ├── ecr.yaml
│               │   ├── gcr.yaml
│               │   └── acr.yaml
│               ├── secrets/
│               │   ├── image-pull-secrets.yaml
│               │   ├── external-secrets.yaml
│               │   └── sealed-secrets.yaml
│               ├── workloads/
│               │   ├── secure-deployment.yaml
│               │   ├── insecure-deployment.yaml
│               │   └── multi-registry-deployment.yaml
│               ├── policies/
│               │   ├── image-pull-policy.yaml
│               │   ├── allowed-registries.yaml
│               │   ├── image-scanning.yaml
│               │   └── signature-verification.yaml
│               ├── testing/
│               │   ├── registry-connectivity.yaml
│               │   ├── secret-rotation.yaml
│               │   └── image-validation.yaml
│               ├── tools/
│               │   ├── registry-cache.yaml
│               │   ├── image-scan-job.yaml
│               │   └── vulnerability-scanner.yaml
│               └── README-exercise.md
├── policies/
│   └── image-security/
│       ├── allowed-registries.yaml
│       ├── image-pull-policies.yaml
│       └── scan-policies.yaml
└── tools/
    └── registry-management/
        ├── registry-proxy.yaml
        └── image-sync.yaml

markdown
# CKS Exercise 07: Private Registry & Image Security

## Learning Objectives:
- Configure secure image pull from private registries
- Manage image pull secrets using best practices
- Implement image security policies
- Set up registry caching and mirroring

## Scenario:
Your organization uses multiple private registries. Implement secure
image pull mechanisms with proper secret management and security controls.

## Tasks:

### Task 1: Configure Image Pull Secrets
1. Create image pull secrets for Docker Hub, GHCR, ECR
2. Use ExternalSecrets Operator for dynamic secret management
3. Attach secrets to ServiceAccounts (not individual pods)

### Task 2: Deploy Secure Workloads
1. Deploy applications using private images
2. Implement imagePullPolicy best practices
3. Use specific image tags (not 'latest')
4. Apply security contexts to containers

### Task 3: Implement Security Policies
1. Create policies to allow only approved registries
2. Require imagePullPolicy on all containers
3. Set up automated image vulnerability scanning
4. Implement image signature verification

### Task 4: Test & Validate
1. Test registry connectivity
2. Validate secret rotation process
3. Run vulnerability scans on images
4. Test failover to registry cache

## Success Criteria:
- [ ] Image pull secrets configured via GitOps
- [ ] Secure workloads deployed from private registries
- [ ] Security policies implemented and enforced
- [ ] Vulnerability scanning integrated
- [ ] Registry caching configured (optional)

## Production Checklist:
- [ ] Image pull secrets managed via external secrets
- [ ] Secrets attached to ServiceAccounts (not pods)
- [ ] No hardcoded credentials in Git
- [ ] ImagePullPolicy set on all containers
- [ ] Only approved registries allowed
- [ ] Regular vulnerability scanning
- [ ] Secret rotation process documented
🚀 DEPLOYMENT WORKFLOW:
In ArgoCD UI:
text
Application 1: private-registry-secrets
Path: gitops/clusters/cks-lab/manifests/07-private-registry/secrets
Namespace: private-registry-lab

Application 2: private-registry-workloads
Path: gitops/clusters/cks-lab/manifests/07-private-registry/workloads
Namespace: private-registry-lab

Application 3: private-registry-policies
Path: gitops/clusters/cks-lab/manifests/07-private-registry/policies
Namespace: private-registry-lab
Testing Commands:
bash
# Test image pull
kubectl run -n private-registry-lab test --image=alpine:latest --rm -it --restart=Never -- sh

# Check secrets
kubectl get secrets -n private-registry-lab --field-selector type=kubernetes.io/dockerconfigjson

# Test ServiceAccount
kubectl describe serviceaccount -n private-registry-lab app-service-account
💡 KEY SECURITY PRACTICES:
Never store credentials in Git: Use ExternalSecrets, SealedSecrets, or Vault

Use ServiceAccounts: Attach pull secrets to ServiceAccounts, not individual pods

Pin versions: Never use :latest tags

Set imagePullPolicy: Always for security-critical, IfNotPresent for performance

Scan images: Integrate vulnerability scanning in CI/CD

Use registry cache: For rate limiting and air-gapped environments

Rotate secrets: Regular credential rotation

🔧 REGISTRY AUTHENTICATION METHODS:
Registry	Authentication Method	Best Practice
Docker Hub	Personal Access Token	Use fine-grained tokens, not passwords
GitHub (GHCR)	GitHub Token	Fine-grained tokens with package permissions
AWS ECR	IAM Roles	Use IRSA (IAM Roles for Service Accounts)
Google GCR	Service Account Key	Workload Identity Federation
Azure ACR	Service Principal	Managed Identity
Want me to:

Add air-gapped registry setup for disconnected environments?

Create CI/CD pipeline with image scanning?

Add image signing/verification with Cosign?

Create multi-cluster registry sync?

This transforms your private registry lab into a complete image security framework for production deployments!