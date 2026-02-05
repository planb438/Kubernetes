# Mock CKS Exam - Task 3: Network Policy Implementation

## Task Description
You are responding to a security incident report. An attacker gained access to a client pod in the `untrusted` namespace and moved laterally to compromise web applications in the `web-apps` namespace.

Your mission: Implement network policies to isolate workloads and prevent lateral movement.

## Requirements
1. **Create a NetworkPolicy** in the `web-apps` namespace that:
   - Allows ingress traffic ONLY from pods in the `trusted-clients` namespace with label `team: security`
   - Restricts access to ports 80 (HTTP) and 443 (HTTPS) only
   - Allows egress traffic from web pods to:
     - Database pods in the `database` namespace on port 5432
     - DNS pods in `kube-system` namespace on port 53
   - Blocks all other ingress and egress traffic

2. **Apply a default deny-all policy** in `web-apps` namespace
3. **Test connectivity** before and after implementation
4. **Verify** that:
   - Trusted clients can access web apps
   - Untrusted clients are blocked
   - Web apps can reach databases
   - Web apps can perform DNS resolution
   - All other traffic is blocked

## Provided Resources
- Namespaces already exist: `web-apps`, `trusted-clients`, `database`, `untrusted`
- Web deployment in `web-apps` with label: `app: web-server`
- Database statefulset in `database` with label: `app: postgres`
- Client pods in both `trusted-clients` (label: `team: security`) and `untrusted`

## Constraints
- Time limit: 15 minutes
- Points: 20/100
- Only use `kubectl` commands
- Do not modify existing pods or services
- NetworkPolicy must be namespace-scoped (no ClusterNetworkPolicy)

## Success Criteria
- Trusted clients can `curl` web service successfully
- Untrusted clients receive timeout/connection refused
- Web pods can connect to database on port 5432
- DNS resolution works from web pods
- No other network communication is possible

## Available Hints (cost: 2 points each)
1. Hint 1: Review NetworkPolicy spec documentation
2. Hint 2: Check `kubectl explain networkpolicy.spec` for syntax