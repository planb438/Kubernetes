Deployment & Usage
bash
# 1. Deploy the mock exam system
kubectl apply -f gitops/clusters/cks-lab/applications/14-mock-exam-setup.yaml

# 2. Start Task 1
kubectl create -f gitops/clusters/cks-lab/manifests/14-mock-tasks/tasks/task-01-rbac-sa-pods/instructions.md
# (Actually, you would read instructions and implement)

# 3. Run verification
kubectl create -f gitops/clusters/cks-lab/manifests/14-mock-tasks/tasks/task-01-rbac-sa-pods/test/verification-job.yaml

# 4. Check score
kubectl get configmap task-01-result -n mock-exam-system -o jsonpath='{.data}' | jq .
Benefits of This Enhanced Structure
Realistic Exam Environment: Timed tasks with point scoring

Automated Verification: Objective scoring eliminates bias

GitOps Integration: All tasks managed through ArgoCD

Progressive Difficulty: From basic RBAC to complex scenarios

Self-Paced Learning: Hints available at point cost

Comprehensive Coverage: Covers all CKS domains

Next Steps for You
Expand Your Task 1: Use the enhanced structure above

Create More Tasks: Add NetworkPolicy, PodSecurity, etc.

Build Verification System: Automated scoring is key

Add Time Pressure: Implement exam timer

Create Dashboard: Visualize progress and scores