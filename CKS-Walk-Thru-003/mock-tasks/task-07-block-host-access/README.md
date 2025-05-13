🛡️ Task 14.7 – Admission Control: Block HostPath, HostNetwork, HostPID
📘 Scenario
Your security team wants to prevent pods from:

Using hostNetwork

Using hostPID

Mounting hostPath volumes

Your job is to enforce this via a Kyverno ClusterPolicy.

🎯 Objectives
Deploy a Kyverno policy named block-host-access

Deny any pod attempting to use:

hostNetwork: true

hostPID: true

Volumes of type hostPath

Test with a violating pod

📁 File Structure
bash
Copy
Edit
cks-labs/
└── 14-mock-tasks/
    └── task-07-block-host-access/
        ├── 01-policy.yaml
        ├── 02-violation-pod.yaml
        ├── cleanup.sh
        └── README.md


---

📘 README.md Summary
markdown
Copy
Edit
# 🛡️ Task 7 – Block Host-Level Pod Access with Kyverno

## 🎯 Goal
Prevent host-level access (hostNetwork, hostPID, hostPath) using admission policy.

## 🛠 Apply Policy
```bash
kubectl apply -f 01-policy.yaml
❌ Test Denial
bash
Copy
Edit
kubectl apply -f 02-violation-pod.yaml
Expected error:

pgsql
Copy
Edit
admission webhook denied the request: hostNetwork or hostPID usage is not allowed
🧼 Cleanup
bash
Copy
Edit
./cleanup.sh
💡 CKS Tip
Block host access to isolate workloads from node compromise

Use Kyverno or Gatekeeper (depending on exam context)

yaml
Copy
Edit
