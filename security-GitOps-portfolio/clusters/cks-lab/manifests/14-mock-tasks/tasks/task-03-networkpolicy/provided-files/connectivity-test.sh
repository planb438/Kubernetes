#!/bin/bash
echo "=== Pre-Task Connectivity Test ==="
echo ""

echo "1. Testing current connectivity (before NetworkPolicy)..."
echo ""

echo "From trusted client to web service:"
kubectl exec -n trusted-clients trusted-client -- \
  curl -s -o /dev/null -w "%{http_code}" http://web-service.web-apps.svc.cluster.local
echo ""

echo "From untrusted client to web service:"
kubectl exec -n untrusted untrusted-client -- \
  curl -s -o /dev/null -w "%{http_code}\n" http://web-service.web-apps.svc.cluster.local
echo ""

echo "From web pod to database:"
kubectl exec -n web-apps deployment/web-app -- \
  sh -c "nc -zv database-service.database.svc.cluster.local 5432 2>&1 | grep -o 'succeeded\|open' || echo 'failed'"
echo ""

echo "Pre-test complete. All connections should currently work."