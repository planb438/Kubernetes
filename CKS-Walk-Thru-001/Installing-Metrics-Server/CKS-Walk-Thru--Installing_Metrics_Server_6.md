-
✅ Installing Metrics Server (v0.7+ recommended)
--
🔍 Purpose
• Collects resource metrics (CPU/memory) from kubelets.

• Required for kubectl top, HPA, and other autoscalers.

--

🛠 Step-by-Step Installation
1. Apply the official Metrics Server manifest:
   
--


kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml

--


2. Patch metrics-server for local development (especially on Vagrant/VirtualBox with no valid cluster DNS or certs): You may need to allow insecure TLS between metrics-server and kubelets:
   
--


kubectl edit deployment metrics-server -n kube-system

--

Then add these args to the containers.args section:

--


- --kubelet-insecure-tls
- --kubelet-preferred-address-types=InternalIP

-

After editing, save and exit to trigger a rolling update.

3. Verify it's working:

--

kubectl get deployment metrics-server -n kube-system
kubectl get apiservices | grep metrics
kubectl top nodes
kubectl top pods -n dev

--


🔐 Security Notes

| Practice | Why It Matters |
| Don’t use --kubelet-insecure-tls in prod | In production, use secure kubelet CA trust chains |
| Ensure RBAC is scoped | Metrics server reads node/pod stats – ensure it doesn’t have write privileges |
| Monitor availability | If metrics-server crashes, HPA and kubectl top break silently |

--


✅ What You Should Remember
◇ It pulls metrics via the Kubelet API, so TLS validation is often an issue in non-cloud or custom setups.

◇ It’s required for CPU-based HPA.

◇ Validate using kubectl top and kubectl describe hpa.


Now that metrics-server is installed and working, shall we proceed with TLS-enabled Ingress?

--
















