✅ Task 1 – ServiceAccount with RBAC (List Pods Only)
📁 Files
bash
Copy
Edit
cks-labs/
└── 14-mock-tasks/
    └── task-01-rbac-sa-pods/
        ├── 00-namespace.yaml
        ├── 01-serviceaccount.yaml
        ├── 02-role.yaml
        ├── 03-rolebinding.yaml
        ├── test-access.sh
        └── README.md

        ---

      📘 README.md (Excerpt)
markdown
Copy
Edit
# 🧪 Task 1 – RBAC: List Pods Only

## 🎯 Goal
Create a ServiceAccount with a Role that allows only `get` and `list` on pods within a namespace.

## 🔧 Setup
```bash
kubectl apply -f 00-namespace.yaml
kubectl apply -f 01-serviceaccount.yaml
kubectl apply -f 02-role.yaml
kubectl apply -f 03-rolebinding.yaml
🧪 Test
bash
Copy
Edit
./test-access.sh
💡 CKS Tip
Use Role for namespace-scope rules

Combine with PodSecurityAdmission + token restrictions for defense-in-depth  