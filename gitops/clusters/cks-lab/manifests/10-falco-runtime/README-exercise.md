Kubernetes/gitops/
├── clusters/
│   └── cks-lab/
│       ├── applications/
│       │   ├── 10-falco-runtime-setup.yaml
│       │   ├── 10-falco-policies.yaml
│       │   ├── 10-falco-testing.yaml
│       │   └── 10-falco-monitoring.yaml
│       └── manifests/
│           └── 10-falco-runtime/
│               ├── infrastructure/
│               │   ├── falco-namespaces.yaml
│               │   ├── falco-service-accounts.yaml
│               │   └── falco-rbac.yaml
│               ├── install/
│               │   ├── falco-helm-values.yaml
│               │   ├── falco-driver-installer.yaml
│               │   ├── falco-updater.yaml
│               │   └── custom-kernel-module.yaml
│               ├── policies/
│               │   ├── falco-rules-basic.yaml
│               │   ├── falco-rules-production.yaml
│               │   ├── falco-rules-compliance.yaml
│               │   ├── falco-rules-custom.yaml
│               │   └── falco-rules-disabled.yaml
│               ├── workloads/
│               │   ├── good-workloads/
│               │   │   ├── secure-deployment.yaml
│               │   │   ├── compliant-pod.yaml
│               │   │   └── audit-friendly-job.yaml
│               │   ├── bad-workloads/
│               │   │   ├── suspicious-shell.yaml
│               │   │   ├── privilege-escalation.yaml
│               │   │   ├── crypto-miner.yaml
│               │   │   └── network-scanner.yaml
│               │   └── test-workloads/
│               │       ├── falco-trigger-pod.yaml
│               │       ├── security-test-job.yaml
│               │       └── compliance-validator.yaml
│               ├── testing/
│               │   ├── falco-trigger-tests.yaml
│               │   ├── rule-validation-job.yaml
│               │   ├── alert-verification.yaml
│               │   └── performance-benchmark.yaml
│               ├── monitoring/
│               │   ├── falco-event-forwarder.yaml
│               │   ├── falco-dashboard.yaml
│               │   ├── alert-manager-config.yaml
│               │   └── slack-notifications.yaml
│               ├── tools/
│               │   ├── falco-exporter.yaml
│               │   ├── falco-ui.yaml
│               │   ├── syscall-generator.yaml
│               │   └── benchmark-tool.yaml
│               └── README-exercise.md
├── policies/
│   └── falco-rules/
│       ├── cis-benchmark-rules.yaml
│       ├── nist-800-53-rules.yaml
│       ├── pci-dss-rules.yaml
│       └── mitre-attack-rules.yaml
└── tools/
    └── falco-tools/
        ├── falcoctl-installer.yaml
        ├── rule-updater.yaml
        └── falco-playground.yaml
        
markdown
# CKS Lab 10 - Runtime Security with Falco

## Lab Objectives
1. Understand runtime security concepts and importance
2. Install and configure Falco for Kubernetes
3. Create custom Falco rules for specific security requirements
4. Test Falco detection capabilities with various attack simulations
5. Integrate Falco alerts with monitoring systems
6. Implement compliance-focused runtime security policies

## Prerequisites
- Kubernetes cluster with Helm
- Access to control plane nodes (for driver installation)
- kubectl configured
- ArgoCD installed

## Lab Setup

### Part 1: Deploy via GitOps
```bash
# Apply all Falco lab applications
kubectl apply -f clusters/cks-lab/applications/10-falco-runtime-setup.yaml
kubectl apply -f clusters/cks-lab/applications/10-falco-policies.yaml
kubectl apply -f clusters/cks-lab/applications/10-falco-testing.yaml
kubectl apply -f clusters/cks-lab/applications/10-falco-monitoring.yaml

# Monitor deployment
argocd app list | grep 10-falco
Part 2: Verify Installation
bash
# Check Falco pods
kubectl get pods -n falco-system

# Check Falco logs
kubectl logs -n falco-system -l app.kubernetes.io/name=falco --tail=10

# Check driver installation
kubectl logs -n falco-system -l app=falco-driver-installer
Exercises
Exercise 1: Basic Falco Setup
Verify Falco installation and driver loading

Test basic rule detection with shell commands

Examine Falco output formats (stdout, file, webhook)

Exercise 2: Custom Rule Development
Create custom rules for application-specific threats

Test rules with simulated attacks

Tune rule priorities and thresholds

Exercise 3: Compliance Monitoring
Implement CIS Benchmark detection rules

Configure NIST 800-53 compliance monitoring

Set up PCI-DSS required detections

Exercise 4: Alert Integration
Configure Falco alerts to Slack/Teams

Set up Prometheus metrics for Falco events

Create Grafana dashboard for runtime security monitoring

Exercise 5: Advanced Threat Detection
Detect container escape attempts

Identify cryptocurrency mining activity

Monitor for data exfiltration patterns

Detect privilege escalation attempts

Testing Scenarios
Scenario 1: Shell in Container
bash
# This should trigger a Falco alert
kubectl run test-shell --image=alpine -n falco-test -- sh -c "sleep 3600"
kubectl exec -n falco-test test-shell -- sh -c "echo 'test'"
Scenario 2: Suspicious Network Activity
bash
# This should trigger network-related alerts
kubectl run test-net --image=alpine -n falco-test -- sh -c "nc -zv localhost 1-100 2>&1"
Scenario 3: File System Monitoring
bash
# This should trigger filesystem alerts
kubectl run test-fs --image=alpine -n falco-test -- sh -c "touch /usr/bin/test-file"
Verification
bash
# Check Falco is detecting events
kubectl logs -n falco-system -l app.kubernetes.io/name=falco --since=1m | grep -E "(WARNING|ERROR|CRITICAL)"

# Check alert forwarding
kubectl logs -n falco-monitoring -l app=falco-event-forwarder --tail=10

# Run comprehensive test suite
kubectl create -f clusters/cks-lab/manifests/10-falco-runtime/testing/falco-trigger-tests.yaml
Cleanup
bash
# Delete ArgoCD applications
kubectl delete -f clusters/cks-lab/applications/10-falco-*.yaml

# Clean up namespaces
kubectl delete namespace falco-system falco-test falco-monitoring

# Uninstall Falco daemonset
kubectl delete daemonset -n falco-system falco
Learning Points
Runtime security is critical for detecting attacks that bypass preventive controls

Falco provides deep visibility into system calls and Kubernetes activities

Custom rules allow tailoring detection to specific environments and threats

Alert integration enables real-time response to security incidents

Compliance frameworks often require runtime security monitoring

Additional Resources
Falco Documentation

Falco Rules Repository

Kubernetes Security Monitoring with Falco

MITRE ATT&CK Framework

text

## **Deployment Commands:**

```bash
# 1. First, commit and push the new lab structure
cd Kubernetes
git add .
git commit -m "Add CKS Lab 10 - Runtime Security with Falco"
git push origin main

# 2. Deploy via ArgoCD
kubectl apply -f gitops/clusters/cks-lab/applications/10-falco-runtime-setup.yaml
kubectl apply -f gitops/clusters/cks-lab/applications/10-falco-policies.yaml
kubectl apply -f gitops/clusters/cks-lab/applications/10-falco-testing.yaml
kubectl apply -f gitops/clusters/cks-lab/applications/10-falco-monitoring.yaml

# 3. Monitor deployment
argocd app sync 10-falco-runtime-setup
argocd app sync 10-falco-policies
argocd app sync 10-falco-testing
argocd app sync 10-falco-monitoring

# 4. Verify installation
kubectl get pods -n falco-system
kubectl get pods -n falco-test
kubectl get pods -n falco-monitoring

# 5. Run tests
kubectl create -f gitops/clusters/cks-lab/manifests/10-falco-runtime/testing/falco-trigger-tests.yaml

# 6. Check alerts
kubectl logs -n falco-system -l app.kubernetes.io/name=falco --tail=100
This follows your exact pattern with:

Multiple ArgoCD applications for different components

Helm-based installation with custom values

Comprehensive testing and verification

Good/bad workload examples

Compliance-focused rules

Monitoring and alerting integration

Complete documentation and exercises

The structure maintains consistency with your other labs while providing a complete Falco runtime security implementation.

