#!/bin/bash
echo "=== Network Policy Validation Script ==="
echo ""

echo "1. Applying NetworkPolicy..."
kubectl apply -f network-policy.yaml
echo ""

echo "2. Waiting for policies to take effect..."
sleep 10

echo ""
echo "3. Testing connectivity..."

echo "   a) Trusted client → Web service (should succeed):"
kubectl exec -n trusted-clients trusted-client -- \
  timeout 5 curl -s -o /dev/null -w "HTTP Status: %{http_code}\n" \
  http://web-service.web-apps.svc.cluster.local
echo ""

echo "   b) Untrusted client → Web service (should fail):"
kubectl exec -n untrusted untrusted-client -- \
  timeout 5 curl -s -o /dev/null -w "Exit code: %{exitcode}\n" \
  http://web-service.web-apps.svc.cluster.local
echo ""

echo "   c) Web pod → Database (should succeed):"
kubectl exec -n web-apps deployment/web-app -c nginx -- \
  sh -c "timeout 5 nc -zv database-service.database.svc.cluster.local 5432 2>&1 | grep -o 'succeeded\|open' || echo 'Connection failed'"
echo ""

echo "   d) DNS resolution from web pod (should succeed):"
kubectl exec -n web-apps deployment/web-app -c nginx -- \
  nslookup kubernetes.default 2>&1 | grep -o "Address.*" || echo "DNS failed"
echo ""

echo "   e) Web pod → External internet (should fail):"
kubectl exec -n web-apps deployment/web-app -c nginx -- \
  timeout 5 curl -s google.com 2>&1 | grep -o "timed out\|failed" || echo "Unexpected success"
echo ""

echo "=== Validation Complete ==="