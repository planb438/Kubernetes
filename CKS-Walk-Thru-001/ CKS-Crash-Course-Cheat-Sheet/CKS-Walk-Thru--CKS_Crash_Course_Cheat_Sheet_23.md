## CKS Crash Course Cheat Sheet

 CKS Crash Course Cheat Sheet




Secrets at Rest
encryption:
  providers:
    - aescbc:
        keys:
          - name: key1
            secret: <base64-encoded-secret>• Location: /etc/kubernetes/encryption-config.yaml



• Kubeadm: --encryption-provider-config



 RBAC Example
kind: Role
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  namespace: dev
  name: pod-reader
rules:
  - apiGroups: [""]
    resources: ["pods"]
    verbs: ["get", "list"]

Falco Alert Test
kubectl run attacker --rm -i --tty --image=alpine -- sh
# Inside container:
ls /etc
 
 
 NetworkPolicy Default Deny
kind: NetworkPolicy
spec:
  podSelector: {}
  policyTypes:
    - Ingress


HPA
kubectl autoscale deployment <name> --cpu-percent=50 --min=1 --max=5

 
 ImagePullSecret
kubectl create secret docker-registry regcred \
  --docker-username=USERNAME \
  --docker-password=PASSWORD \
  --docker-email=EMAIL

 Audit Log Location
/var/log/kubernetes/audit.log


Cosign
cosign generate-key-pair
cosign sign <image>
cosign verify <image>
Pro Tip: Always know where logs go, what each YAML field does, and how to quickly debug failure states (esp. PSA, CNI, RBAC, Admission Webhooks).
Practice Builds: Rebuild your cluster in under 1 hour with full security stack for peak readiness.




