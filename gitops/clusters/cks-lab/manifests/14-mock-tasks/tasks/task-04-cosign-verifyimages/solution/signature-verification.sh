#!/bin/bash
echo "=== Cosign Image Verification Test Script ==="
echo ""

# Load environment
source .env 2>/dev/null || true

echo "1. Creating test namespace..."
kubectl create namespace cosign-test --dry-run=client -o yaml | kubectl apply -f -

echo ""
echo "2. Applying Kyverno policy..."
kubectl apply -f kyverno-policy.yaml

echo ""
echo "3. Testing signed image deployment (should succeed)..."
cat <<EOF | kubectl apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: test-signed-deployment
  namespace: cosign-test
spec:
  replicas: 1
  selector:
    matchLabels:
      app: test-signed
  template:
    metadata:
      labels:
        app: test-signed
    spec:
      containers:
      - name: app
        image: ghcr.io/company/production/signed-app:v1.0.0
        ports:
        - containerPort: 8080
EOF

if [[ $? -eq 0 ]]; then
    echo "   ✓ Signed image deployment initiated"
    echo "   Checking deployment status..."
    sleep 5
    kubectl get deployment test-signed-deployment -n cosign-test
else
    echo "   ✗ Signed image deployment failed unexpectedly"
fi

echo ""
echo "4. Testing unsigned image deployment (should fail)..."
cat <<EOF | kubectl apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: test-unsigned-deployment
  namespace: cosign-test
spec:
  replicas: 1
  selector:
    matchLabels:
      app: test-unsigned
  template:
    metadata:
      labels:
        app: test-unsigned
    spec:
      containers:
      - name: app
        image: ghcr.io/company/production/unsigned-app:latest
        ports:
        - containerPort: 8080
EOF

if [[ $? -ne 0 ]]; then
    echo "   ✓ Unsigned image correctly blocked"
    echo "   Error message should indicate signature verification failed"
else
    echo "   ✗ Unsigned image was not blocked (policy failure)"
fi

echo ""
echo "5. Testing emergency patch in kube-system (should succeed)..."
cat <<EOF | kubectl apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: test-emergency-patch
  namespace: kube-system
  annotations:
    emergency-patch: "true"
    emergency-reason: "Zero-day vulnerability patch"
    ticket-reference: "SEC-2024-001"
spec:
  replicas: 1
  selector:
    matchLabels:
      app: test-emergency
  template:
    metadata:
      labels:
        app: test-emergency
      annotations:
        emergency-patch: "true"
        emergency-reason: "Zero-day vulnerability patch"
    spec:
      containers:
      - name: nginx
        image: nginx:1.25
        ports:
        - containerPort: 80
EOF

if [[ $? -eq 0 ]]; then
    echo "   ✓ Emergency patch deployed successfully"
else
    echo "   ✗ Emergency patch deployment failed"
fi

echo ""
echo "6. Testing emergency patch without annotation (should fail)..."
cat <<EOF | kubectl apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: test-invalid-emergency
  namespace: kube-system
spec:
  replicas: 1
  selector:
    matchLabels:
      app: test-invalid-emergency
  template:
    metadata:
      labels:
        app: test-invalid-emergency
    spec:
      containers:
      - name: nginx
        image: nginx:1.25
        ports:
        - containerPort: 80
EOF

if [[ $? -ne 0 ]]; then
    echo "   ✓ Invalid emergency correctly blocked"
else
    echo "   ✗ Invalid emergency was not blocked"
fi

echo ""
echo "=== Verification Tests Complete ==="
echo ""
echo "Summary:"
echo "- Signed images should deploy successfully"
echo "- Unsigned images should be blocked"
echo "- Emergency patches with annotation should deploy"
echo "- Invalid emergencies should be blocked"
echo ""
echo "Check Kyverno logs for verification details:"
echo "kubectl logs -n kyverno -l app.kubernetes.io/name=kyverno --tail=50"