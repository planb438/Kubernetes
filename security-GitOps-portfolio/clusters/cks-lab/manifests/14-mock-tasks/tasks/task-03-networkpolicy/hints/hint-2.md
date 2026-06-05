# Hint 2: Specific Requirements for This Task (Cost: 2 points)

## Requirements Breakdown
1. **Allow from trusted-clients namespace only**:
   ```yaml
   namespaceSelector:
     matchLabels:
       kubernetes.io/metadata.name: trusted-clients
Only pods with label team: security:

yaml
podSelector:
  matchLabels:
    team: security
Ports 80 and 443 only:

yaml
ports:
- protocol: TCP
  port: 80
- protocol: TCP
  port: 443
Egress to database on port 5432:

yaml
egress:
- to:
  - namespaceSelector:
      matchLabels:
        kubernetes.io/metadata.name: database
    podSelector:
      matchLabels:
        app: postgres
  ports:
  - protocol: TCP
    port: 5432
DNS egress to kube-system:

yaml
- to:
  - namespaceSelector:
      matchLabels:
        kubernetes.io/metadata.name: kube-system
    podSelector:
      matchLabels:
        k8s-app: kube-dns
  ports:
  - protocol: UDP
    port: 53
  - protocol: TCP
    port: 53
Testing Commands
bash
# Test connectivity quickly
kubectl exec -n trusted-clients trusted-client -- curl -I http://web-service.web-apps

# Check if policy is applied
kubectl describe networkpolicy -n web-apps

# View pod labels
kubectl get pods --show-labels -n trusted-clients