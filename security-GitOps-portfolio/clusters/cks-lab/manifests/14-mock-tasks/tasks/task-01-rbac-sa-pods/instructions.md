# Mock CKS Exam - Task 1: RBAC & Service Account Security

## Task Description
You are a Kubernetes security administrator. The development team needs a service account that can:
1. List and get pods ONLY in the `app-team1` namespace
2. Create and update configmaps ONLY in the `app-team1` namespace
3. **NOT** have any permissions in other namespaces
4. **NOT** be able to delete any resources
5. The service account should **NOT** automatically mount tokens

## Requirements
1. Create namespace: `app-team1`
2. Create service account: `cicd-token` in `app-team1`
3. Create appropriate Role with minimum required permissions
4. Create RoleBinding to associate the Role with the ServiceAccount
5. Apply security best practices (least privilege, no token auto-mount)

## Success Criteria
- Service account can list pods in `app-team1`
- Service account can create configmaps in `app-team1`
- Service account cannot access `default` namespace
- Service account cannot delete resources
- No token automatically mounted

## Time Limit: 10 minutes
Points: 15/100

## Hints Available: 2 (cost: 2 points each)