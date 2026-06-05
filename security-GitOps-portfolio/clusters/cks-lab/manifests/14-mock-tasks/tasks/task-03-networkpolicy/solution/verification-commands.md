# Verification Commands for Task 3

## Check Applied Policies
```bash
kubectl get networkpolicies -n web-apps
kubectl describe networkpolicy web-apps-isolation -n web-apps
kubectl describe networkpolicy default-deny-all -n web-apps


Test Connectivity Manually
From Trusted Client (should work):
bash
kubectl exec -n trusted-clients trusted-client -- \
  curl -v http://web-service.web-apps.svc.cluster.local
From Untrusted Client (should fail):
bash
kubectl exec -n untrusted untrusted-client -- \
  timeout 5 curl -v http://web-service.web-apps.svc.cluster.local
Web to Database (should work):
bash
kubectl exec -n web-apps deployment/web-app -c nginx -- \
  nc -zv database-service.database.svc.cluster.local 5432
DNS from Web (should work):
bash
kubectl exec -n web-apps deployment/web-app -c nginx -- \
  nslookup kubernetes.default.svc.cluster.local
External from Web (should fail):
bash
kubectl exec -n web-apps deployment/web-app -c nginx -- \
  timeout 5 curl -s https://google.com
View NetworkPolicy Details
bash
kubectl get networkpolicy web-apps-isolation -n web-apps -o yaml
kubectl get networkpolicy default-deny-all -n web-apps -o yaml
Cleanup (if needed)
bash
kubectl delete networkpolicy -n web-apps --all
text

### **File 4: Test Verification Job**
**`task-03-networkpolicy/test/verification-job.yaml`**
```yaml
apiVersion: batch/v1
kind: Job
metadata:
  name: task-03-verification
  namespace: mock-exam-system
  annotations:
    task: "03"
    points: "20"
    cks-domain: "Cluster Hardening"
spec:
  ttlSecondsAfterFinished: 300
  template:
    spec:
      serviceAccountName: exam-verifier
      containers:
      - name: verifier
        image: bitnami/kubectl:latest
        command: ["/bin/bash", "-c"]
        args:
        - |
          echo "=== Task 3 Verification: Network Policy ==="
          echo ""
          
          TOTAL_POINTS=0
          MAX_POINTS=20
          
          # Check 1: NetworkPolicy exists (4 points)
          echo "1. Checking NetworkPolicy resources..."
          if kubectl get networkpolicy web-apps-isolation -n web-apps >/dev/null 2>&1; then
            echo "   ✓ web-apps-isolation policy exists"
            if kubectl get networkpolicy default-deny-all -n web-apps >/dev/null 2>&1; then
              echo "   ✓ default-deny-all policy exists"
              TOTAL_POINTS=$((TOTAL_POINTS + 4))
            else
              echo "   ✗ default-deny-all policy missing"
            fi
          else
            echo "   ✗ web-apps-isolation policy missing"
          fi
          
          # Check 2: Policy configuration (6 points)
          echo ""
          echo "2. Checking policy configuration..."
          POLICY=$(kubectl get networkpolicy web-apps-isolation -n web-apps -o yaml)
          
          CONFIG_CORRECT=true
          
          # Check for trusted-clients namespace selector
          if ! echo "$POLICY" | grep -q "kubernetes.io/metadata.name: trusted-clients"; then
            echo "   ✗ Missing trusted-clients namespace selector"
            CONFIG_CORRECT=false
          fi
          
          # Check for team: security pod selector
          if ! echo "$POLICY" | grep -q "team: security"; then
            echo "   ✗ Missing team: security pod selector"
            CONFIG_CORRECT=false
          fi
          
          # Check for port 80 and 443
          if ! echo "$POLICY" | grep -q "port: 80" || ! echo "$POLICY" | grep -q "port: 443"; then
            echo "   ✗ Missing port restrictions (80, 443)"
            CONFIG_CORRECT=false
          fi
          
          # Check for database egress
          if ! echo "$POLICY" | grep -q "port: 5432" || ! echo "$POLICY" | grep -q "app: postgres"; then
            echo "   ✗ Missing database egress rule"
            CONFIG_CORRECT=false
          fi
          
          # Check for DNS egress
          if ! echo "$POLICY" | grep -q "port: 53"; then
            echo "   ✗ Missing DNS egress rule"
            CONFIG_CORRECT=false
          fi
          
          if [ "$CONFIG_CORRECT" = true ]; then
            echo "   ✓ All policy configurations correct"
            TOTAL_POINTS=$((TOTAL_POINTS + 6))
          fi
          
          # Check 3: Connectivity tests (10 points)
          echo ""
          echo "3. Running connectivity tests..."
          
          # Test 3a: Trusted client access (2 points)
          echo "   a) Trusted client → Web service..."
          kubectl exec -n trusted-clients trusted-client -- \
            timeout 5 curl -s -o /dev/null http://web-service.web-apps.svc.cluster.local
          if [ $? -eq 0 ]; then
            echo "      ✓ Trusted client can access web"
            TOTAL_POINTS=$((TOTAL_POINTS + 2))
          else
            echo "      ✗ Trusted client cannot access web"
          fi
          
          # Test 3b: Untrusted client blocked (2 points)
          echo "   b) Untrusted client → Web service..."
          kubectl exec -n untrusted untrusted-client -- \
            timeout 5 curl -s -o /dev/null http://web-service.web-apps.svc.cluster.local
          if [ $? -ne 0 ]; then
            echo "      ✓ Untrusted client blocked"
            TOTAL_POINTS=$((TOTAL_POINTS + 2))
          else
            echo "      ✗ Untrusted client can access (security failure)"
          fi
          
          # Test 3c: Web to database (2 points)
          echo "   c) Web pod → Database..."
          kubectl exec -n web-apps deployment/web-app -c nginx -- \
            timeout 5 nc -zv database-service.database.svc.cluster.local 5432 >/dev/null 2>&1
          if [ $? -eq 0 ]; then
            echo "      ✓ Web can access database"
            TOTAL_POINTS=$((TOTAL_POINTS + 2))
          else
            echo "      ✗ Web cannot access database"
          fi
          
          # Test 3d: DNS resolution (2 points)
          echo "   d) DNS resolution from web..."
          kubectl exec -n web-apps deployment/web-app -c nginx -- \
            nslookup kubernetes.default >/dev/null 2>&1
          if [ $? -eq 0 ]; then
            echo "      ✓ DNS resolution works"
            TOTAL_POINTS=$((TOTAL_POINTS + 2))
          else
            echo "      ✗ DNS resolution failed"
          fi
          
          # Test 3e: External access blocked (2 points)
          echo "   e) Web pod → External internet..."
          kubectl exec -n web-apps deployment/web-app -c nginx -- \
            timeout 5 curl -s https://google.com >/dev/null 2>&1
          if [ $? -ne 0 ]; then
            echo "      ✓ External access blocked (correct)"
            TOTAL_POINTS=$((TOTAL_POINTS + 2))
          else
            echo "      ✗ Web can access external internet (security failure)"
          fi
          
          echo ""
          echo "=== Verification Complete ==="
          echo "Total Points: $TOTAL_POINTS/$MAX_POINTS"
          
          # Store result
          cat > /tmp/task-03-result.json << EOF
          {
            "task": "03",
            "name": "Network Policy Implementation",
            "points": $TOTAL_POINTS,
            "max_points": $MAX_POINTS,
            "timestamp": "$(date -Iseconds)",
            "details": {
              "policies_exist": $( [ $TOTAL_POINTS -ge 4 ] && echo "true" || echo "false" ),
              "configuration_correct": $( [ "$CONFIG_CORRECT" = true ] && echo "true" || echo "false" ),
              "trusted_access": $( [ $TOTAL_POINTS -ge 6 ] && echo "true" || echo "false" ),
              "untrusted_blocked": $( [ $TOTAL_POINTS -ge 8 ] && echo "true" || echo "false" ),
              "database_access": $( [ $TOTAL_POINTS -ge 10 ] && echo "true" || echo "false" ),
              "dns_works": $( [ $TOTAL_POINTS -ge 12 ] && echo "true" || echo "false" ),
              "external_blocked": $( [ $TOTAL_POINTS -ge 14 ] && echo "true" || echo "false" )
            }
          }
          EOF
          
          kubectl create configmap task-03-result \
            --from-file=/tmp/task-03-result.json \
            -n mock-exam-system \
            --dry-run=client -o yaml | kubectl apply -f -
          
        restartPolicy: Never
  backoffLimit: 0