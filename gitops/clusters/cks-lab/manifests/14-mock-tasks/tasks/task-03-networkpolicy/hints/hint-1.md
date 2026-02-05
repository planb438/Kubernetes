# Hint 1: NetworkPolicy Basics (Cost: 2 points)

## Key Concepts
1. **podSelector**: Selects pods to which the policy applies
2. **namespaceSelector**: Selects namespaces from which traffic is allowed
3. **policyTypes**: Can be "Ingress", "Egress", or both
4. **ingress/egress rules**: Define what traffic is allowed

## Example Structure
```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: example
  namespace: target-ns
spec:
  podSelector:
    matchLabels:
      app: myapp
  policyTypes:
  - Ingress
  ingress:
  - from:
    - namespaceSelector:
        matchLabels:
          environment: prod
      podSelector:
        matchLabels:
          role: frontend
    ports:
    - protocol: TCP
      port: 80




Useful Commands
bash
# Check if NetworkPolicy resource is available
kubectl api-resources | grep networkpolicy

# View existing policies
kubectl get networkpolicies --all-namespaces

# Explain NetworkPolicy fields
kubectl explain networkpolicy.spec