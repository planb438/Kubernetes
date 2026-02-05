task-03-networkpolicy/
├── instructions.md
├── provided-files/
│   ├── initial-namespaces.yaml
│   ├── existing-pods.yaml
│   └── connectivity-test.sh
├── solution/
│   ├── network-policy.yaml
│   ├── validation-script.sh
│   └── verification-commands.md
├── test/
│   ├── verification-job.yaml
│   ├── test-scenarios.yaml
│   └── expected-results.yaml
├── hints/
│   ├── hint-1.md
│   └── hint-2.md
└── README.md


# Task 3: Network Policy Implementation

## Overview
This task tests your ability to implement Kubernetes Network Policies to control pod-to-pod communication and prevent lateral movement attacks.

## Learning Objectives
- Understand Kubernetes NetworkPolicy API
- Implement ingress and egress controls
- Use namespaceSelector and podSelector
- Test network isolation
- Apply security best practices for microsegmentation

## Prerequisites
- Basic understanding of Kubernetes networking
- Familiarity with `kubectl` commands
- Understanding of labels and selectors

## Task Structure
- `instructions.md`: Complete task description and requirements
- `provided-files/`: Initial setup files (namespaces, pods, services)
- `solution/`: Complete solution files
- `test/`: Verification and scoring system
- `hints/`: Helpful hints (with point cost)

## Time Management
- Recommended time: 15 minutes
- Points: 20/100
- Hint cost: 2 points each

## Key Concepts Tested
1. **NetworkPolicy Specification**
2. **Ingress/Egress Controls**
3. **Namespace Isolation**
4. **Port-based Restrictions**
5. **Connectivity Testing**

## Success Tips
1. Read all requirements carefully
2. Test each requirement individually
3. Verify both allowed and blocked traffic
4. Check policy application with `kubectl describe`
5. Use the validation script to confirm functionality

## Related CKS Domains
- Cluster Hardening
- System Hardening
- Supply Chain Security
- Monitoring, Logging and Runtime Security