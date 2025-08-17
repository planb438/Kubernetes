 Starting with Prometheus + Grafana will give you comprehensive monitoring capabilities for your Kubernetes cluster. Here's a step-by-step guide to install and configure them using Helm in your home lab:

Step 1: Add Helm Repositories
Ensure you have the Prometheus Community Helm repo:

bash
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update
Step 2: Install kube-prometheus-stack
This Helm chart bundles Prometheus, Grafana, Alertmanager, and essential Kubernetes monitoring tools (like Node Exporter and Kube-State-Metrics).

bash
helm install prometheus-stack prometheus-community/kube-prometheus-stack \
  --namespace monitoring \
  --create-namespace \
  --set prometheus.prometheusSpec.serviceMonitorSelectorNilUsesHelmValues=false \
  --set grafana.service.type=NodePort
Flags Explained:
--namespace monitoring: Creates a dedicated namespace.

serviceMonitorSelectorNilUsesHelmValues=false: Ensures Prometheus discovers all ServiceMonitors (not just Helm-managed ones).

grafana.service.type=NodePort: Exposes Grafana on a NodePort for easy access.

Step 3: Verify Installation
Check if pods are running:

bash
kubectl get pods -n monitoring
Expected output (look for Running status):

text
NAME                                                     READY   STATUS    RESTARTS   AGE
prometheus-stack-kube-prom-operator-xxxxx                1/1     Running   0          2m
prometheus-stack-grafana-xxxxx                           2/2     Running   0          2m
prometheus-stack-kube-state-metrics-xxxxx               1/1     Running   0          2m
prometheus-stack-prometheus-node-exporter-xxxxx         1/1     Running   0          2m
Step 4: Access Grafana
Get the NodePort:

bash
kubectl get svc -n monitoring prometheus-stack-grafana
Example output:

text
NAME                         TYPE       CLUSTER-IP     PORT(S)        AGE
prometheus-stack-grafana     NodePort   10.96.123.45  80:32345/TCP   5m
Here, Grafana is exposed on port 32345.

Access Grafana:

Open a browser and navigate to: http://<your-worker-node-ip>:32345

Default credentials:

Username: admin

Password: Get it with:

bash
kubectl get secret -n monitoring prometheus-stack-grafana -o jsonpath='{.data.admin-password}' | base64 --decode
Step 5: Access Prometheus
Prometheus is cluster-internal by default. To access it:

Port-forward:

bash
kubectl port-forward -n monitoring svc/prometheus-stack-kube-prom-prometheus 9090
Visit http://localhost:9090 in your browser.

Step 6: Import Dashboards in Grafana
Grafana auto-imports Kubernetes dashboards. To manually add more:

Go to Dashboards > Import.

Use dashboard IDs like:

Kubernetes Cluster: 6417

Nodes: 1860

Pods: 6418

Optional: Persistence
To retain metrics/data across reboots, add these flags during Helm install:

bash
--set prometheus.prometheusSpec.storageSpec.volumeClaimTemplate.spec.storageClassName=<your-storage-class> \
--set prometheus.prometheusSpec.storageSpec.volumeClaimTemplate.spec.resources.requests.storage=10Gi \
--set grafana.persistence.enabled=true \
--set grafana.persistence.size=5Gi
Troubleshooting
No Targets in Prometheus?
Ensure your kubelet and cAdvisor metrics are exposed (check kubectl top nodes works).

Grafana Login Issues?
Reset the password:

bash
kubectl patch secret -n monitoring prometheus-stack-grafana -p '{"data":{"admin-password":"'$(echo "newpassword" | base64)'"}}'
Next Steps
Set up alerts in Alertmanager (included in the stack).

Integrate with Loki for logs (your next project?).

Secure Grafana/Prometheus with Ingress + TLS (using Cert-Manager).

Let me know if you hit any snags! Happy monitoring! 📊🔍
