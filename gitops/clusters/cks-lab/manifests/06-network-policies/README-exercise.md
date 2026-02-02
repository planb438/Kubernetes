markdown
# CKS Exercise 06: Network Policies & Zero-Trust Security

## Learning Objectives:
- Implement Kubernetes Network Policies for microservices
- Apply zero-trust network principles
- Design tiered network architecture
- Test and validate network security controls

## Scenario:
You are securing a microservices application with multiple tiers.
Implement network policies to enforce least-privilege communication.

## Tasks:

### Task 1: Deploy Tiered Architecture
1. Deploy namespaces (web, app, data, management)
2. Deploy sample workloads in each tier
3. Apply default deny-all policies

### Task 2: Implement Least-Privilege Policies
1. Allow web → app communication (HTTP/HTTPS only)
2. Allow app → data communication (database ports only)
3. Block data → app/web communication
4. Allow monitoring access from management tier

### Task 3: Control Egress Traffic
1. Restrict egress to external services
2. Block access to cloud metadata services
3. Allow DNS only to internal DNS servers
4. Create allow-list for required external APIs

### Task 4: Test & Validate
1. Run network penetration tests
2. Validate policies allow required traffic
3. Verify policies block unauthorized traffic
4. Generate compliance report

## Success Criteria:
- [ ] Tiered architecture deployed via GitOps
- [ ] Network policies applied to all tiers
- [ ] Least-privilege communication enforced
- [ ] Egress traffic controlled
- [ ] Penetration tests passed
- [ ] Documentation complete

## Production Checklist:
- [ ] Default deny-all policies in place
- [ ] Namespace isolation implemented
- [ ] Tiered communication controls
- [ ] Egress to metadata blocked
- [ ] DNS restrictions applied
- [ ] Regular network scanning
- [ ] Policy violation alerts
🚀 DEPLOYMENT WORKFLOW:
In ArgoCD UI:
text
Application 1: network-policy-namespaces
Path: gitops/clusters/cks-lab/manifests/06-network-policies/namespaces

Application 2: network-policy-workloads
Path: gitops/clusters/cks-lab/manifests/06-network-policies/workloads

Application 3: network-policies
Path: gitops/clusters/cks-lab/manifests/06-network-policies/policies
Testing Commands:
bash
# Test network connectivity
kubectl run -n tier-web test --image=alpine/curl --rm -it --restart=Never -- \
  curl -v http://backend.tier-app.svc.cluster.local:8080

# Check network policies
kubectl get networkpolicies --all-namespaces

# Visualize network flows (if Weave Net installed)
kubectl get pods -n kube-system | grep weave
💡 KEY NETWORK POLICY CONCEPTS:
Default Deny: Start with deny-all, add allow rules

Namespace Isolation: Control cross-namespace traffic

Pod Selectors: Granular control based on labels

Port Restrictions: Allow only necessary ports

Egress Controls: Control outbound traffic

CIDR Blocks: Allow/block specific IP ranges

🔧 CNI SUPPORT CHECK:
Network Policies require CNI plugins that support them:

Calico (Most feature-rich)

Cilium (eBPF-based, recommended)

Weave Net

Antrea

Check your CNI:

bash
kubectl get pods -n kube-system | grep -E "calico|cilium|weave|antrea"
Want me to:

Add Cilium Network Policies (L7 policies)?

Create Service Mesh integration (Istio + Network Policies)?

Add compliance framework (NIST, CIS benchmarks)?

Create automated policy generator?

This transforms your network policy lab into a complete zero-trust security implementation for production!

