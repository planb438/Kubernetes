#!/bin/bash
echo "=== Container Capability Check Script ==="
echo ""

echo "1. Checking current pod capabilities..."
echo ""

# Get pod name
POD_NAME=$(kubectl get pods -n production -l app=frontend -o jsonpath='{.items[0].metadata.name}')

if [ -z "$POD_NAME" ]; then
    echo "No frontend pod found in production namespace"
    exit 1
fi

echo "Pod: $POD_NAME"
echo ""

echo "2. Checking security context..."
kubectl get pod $POD_NAME -n production -o jsonpath='{.spec.containers[0].securityContext}' | jq .
echo ""

echo "3. Checking capabilities inside container..."
echo "Effective capabilities (CapEff):"
kubectl exec -n production $POD_NAME -- sh -c 'cat /proc/self/status | grep Cap'
echo ""

echo "4. Checking user ID..."
kubectl exec -n production $POD_NAME -- id
echo ""

echo "5. Checking filesystem permissions..."
echo "Root filesystem is read-only? (should show ro)"
kubectl exec -n production $POD_NAME -- mount | grep " / "
echo ""

echo "6. Checking process list..."
kubectl exec -n production $POD_NAME -- ps aux
echo ""

echo "7. Testing NET_BIND_SERVICE capability..."
echo "Attempting to bind to port 80 (should succeed):"
kubectl exec -n production $POD_NAME -- sh -c '
  if nc -l -p 80 -w 1 2>&1 | grep -q "Permission denied"; then
    echo "  ✗ Cannot bind to port 80 (capability missing)"
  else
    echo "  ✓ Can bind to port 80 (NET_BIND_SERVICE present)"
  fi
'
echo ""

echo "8. Testing dangerous capabilities (should fail)..."
echo "Testing NET_RAW (should not be available):"
kubectl exec -n production $POD_NAME -- sh -c '
  if ping -c 1 -W 1 127.0.0.1 2>&1 | grep -q "Operation not permitted"; then
    echo "  ✓ NET_RAW correctly not available"
  else
    echo "  ✗ NET_RAW available (security risk)"
  fi
'
echo ""

echo "9. Checking resource limits..."
kubectl get pod $POD_NAME -n production -o jsonpath='{.spec.containers[0].resources}' | jq .
echo ""

echo "10. Checking health probes..."
kubectl describe pod $POD_NAME -n production | grep -A5 "Liveness\|Readiness"
echo ""

echo "=== Security Check Summary ==="
echo ""
echo "Expected Results:"
echo "✓ Running as non-root user (UID > 10000)"
echo "✓ NET_BIND_SERVICE capability present"
echo "✓ NET_RAW capability NOT present"
echo "✓ Read-only root filesystem"
echo "✓ Resource limits set"
echo "✓ Health probes configured"
echo ""
echo "Check complete."