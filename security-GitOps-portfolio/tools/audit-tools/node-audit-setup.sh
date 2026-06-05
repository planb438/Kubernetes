#!/bin/bash
# node-audit-setup.sh
# Setup audit logging on control plane nodes

set -euo pipefail

echo "========================================="
echo "  CKS Lab 09 - Node Audit Setup"
echo "========================================="
echo ""

# Configuration
AUDIT_DIR="/var/log/kubernetes"
APISERVER_MANIFEST="/etc/kubernetes/manifests/kube-apiserver.yaml"
BACKUP_DIR="/etc/kubernetes/backups"

# Create backup
mkdir -p "$BACKUP_DIR"
BACKUP_FILE="$BACKUP_DIR/kube-apiserver.yaml.backup.$(date +%Y%m%d-%H%M%S)"
cp "$APISERVER_MANIFEST" "$BACKUP_FILE"
echo "✓ Backup created: $BACKUP_FILE"

# Create audit directory
mkdir -p "$AUDIT_DIR"
chmod 750 "$AUDIT_DIR"
echo "✓ Audit directory created: $AUDIT_DIR"

# Download audit policy from your repo
curl -sSL "https://raw.githubusercontent.com/planb438/Kubernetes/main/gitops/clusters/cks-lab/manifests/09-audit-logs/policies/audit-policy-basic.yaml" \
  -o "/etc/kubernetes/audit-policy.yaml"
echo "✓ Audit policy downloaded"

# Patch kube-apiserver
echo ""
echo "Patching kube-apiserver..."
echo ""

# Check if audit is already configured
if grep -q "audit-log-path" "$APISERVER_MANIFEST"; then
    echo "⚠ Audit already configured. Updating..."
    # Remove existing audit config
    sed -i '/--audit-log/d' "$APISERVER_MANIFEST"
    sed -i '/--audit-policy/d' "$APISERVER_MANIFEST"
    sed -i '/audit-log/d' "$APISERVER_MANIFEST"
    sed -i '/audit-policy/d' "$APISERVER_MANIFEST"
fi

# Add audit arguments
sed -i '/- kube-apiserver/a\    - --audit-log-maxage=30' "$APISERVER_MANIFEST"
sed -i '/- kube-apiserver/a\    - --audit-log-maxbackup=10' "$APISERVER_MANIFEST"
sed -i '/- kube-apiserver/a\    - --audit-log-maxsize=100' "$APISERVER_MANIFEST"
sed -i '/- kube-apiserver/a\    - --audit-log-path=/var/log/kubernetes/audit.log' "$APISERVER_MANIFEST"
sed -i '/- kube-apiserver/a\    - --audit-policy-file=/etc/kubernetes/audit-policy.yaml' "$APISERVER_MANIFEST"
sed -i '/- kube-apiserver/a\    - --audit-log-format=json' "$APISERVER_MANIFEST"

# Add volumes
if ! grep -q "name: audit-log" "$APISERVER_MANIFEST"; then
    sed -i '/volumes:/a\  - hostPath:\n    path: /var/log/kubernetes\n    type: DirectoryOrCreate\n  name: audit-log' "$APISERVER_MANIFEST"
fi

if ! grep -q "name: audit-policy" "$APISERVER_MANIFEST"; then
    sed -i '/volumes:/a\  - hostPath:\n    path: /etc/kubernetes/audit-policy.yaml\n    type: File\n  name: audit-policy' "$APISERVER_MANIFEST"
fi

# Add volume mounts
if ! grep -q "mountPath: /var/log/kubernetes" "$APISERVER_MANIFEST"; then
    sed -i '/volumeMounts:/a\    - mountPath: /var/log/kubernetes\n      name: audit-log' "$APISERVER_MANIFEST"
fi

if ! grep -q "mountPath: /etc/kubernetes/audit-policy.yaml" "$APISERVER_MANIFEST"; then
    sed -i '/volumeMounts:/a\    - mountPath: /etc/kubernetes/audit-policy.yaml\n      name: audit-policy\n      readOnly: true' "$APISERVER_MANIFEST"
fi

echo "✓ kube-apiserver patched"
echo ""
echo "Restarting kubelet..."
systemctl restart kubelet

echo ""
echo "========================================="
echo "  Setup Complete!"
echo "========================================="
echo ""
echo "Next steps:"
echo "1. Wait 1-2 minutes for kube-apiserver to restart"
echo "2. Verify with: systemctl status kubelet"
echo "3. Check audit logs: tail -f /var/log/kubernetes/audit.log"
echo "4. Deploy ArgoCD applications:"
echo "   kubectl apply -f gitops/clusters/cks-lab/applications/09-*.yaml"
echo ""