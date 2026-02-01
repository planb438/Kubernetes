#!/bin/bash

echo "=== Creating Kind Cluster with Encryption at Rest ==="

# Generate encryption key
mkdir -p encryption-config
openssl rand -base64 32 > encryption-config/encryption-key

# Create encryption configuration
cat > encryption-config/encryption-config.yaml <<EOF
apiVersion: apiserver.config.k8s.io/v1
kind: EncryptionConfiguration
resources:
  - resources:
      - secrets
    providers:
      - aescbc:
          keys:
            - name: key1
              secret: $(cat encryption-config/encryption-key | base64)
      - identity: {}
EOF

# Create kind cluster
kind create cluster --name encrypted-cluster --config kind-encrypted-cluster.yaml

echo "=== Cluster created with encryption at rest enabled ==="
echo "Test with: kubectl create secret generic test --from-literal=key=value"
echo "Verify with: kubectl get secret test -o yaml"