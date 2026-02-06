Real Exam Considerations for Audit Logging
Production vs Exam Reality
In the real CKS exam:

You CAN modify /etc/kubernetes/manifests/ - Exam clusters often allow this

You MUST know how to audit logs - Critical skill tested

Time is limited - 2 hours for ~15-20 tasks

Actual Exam-Style Solution
For a real exam, your original approach is more realistic:

bash
#!/bin/bash
# Exam-style solution (2 minutes max)

# 1. Create namespace
kubectl create ns audit-task

# 2. Create test secret
kubectl create secret generic demo-secret \
  --from-literal=token=test \
  -n audit-task

# 3. Create audit policy file
cat > audit-policy.yaml <<EOF
apiVersion: audit.k8s.io/v1
kind: Policy
rules:
- level: Metadata
  resources:
  - group: ""
    resources: ["secrets"]
  namespaces: ["audit-task"]
EOF

# 4. Apply to control plane (exam allows this)
sudo cp audit-policy.yaml /etc/kubernetes/
sudo sed -i '/- kube-apiserver/a\    - --audit-policy-file=/etc/kubernetes/audit-policy.yaml\n    - --audit-log-path=/var/log/kubernetes/audit.log' \
  /etc/kubernetes/manifests/kube-apiserver.yaml

# 5. Test (wait for api-server restart)
sleep 30
kubectl get secret demo-secret -n audit-task

# 6. Verify
sudo grep demo-secret /var/log/kubernetes/audit.log | jq .
