#!/bin/bash
echo "=== Creating Test Images for Cosign Verification ==="
echo ""

echo "1. Creating signed test image..."
# Build the image
docker build -f ../provided-files/test-images/Dockerfile.signed \
  -t ghcr.io/company/production/signed-app:v1.0.0 \
  ../provided-files/test-images/

echo ""
echo "2. Creating unsigned test image..."
docker build -f ../provided-files/test-images/Dockerfile.signed \
  -t ghcr.io/company/production/unsigned-app:latest \
  ../provided-files/test-images/

echo ""
echo "3. Signing the production image with Cosign..."
# Note: In real scenario, you'd have a private key
# This is simulation for exam purposes
echo "Simulating Cosign signing..."
cat > /tmp/signature.sim << EOF
-----BEGIN SIGNATURE-----
Simulated signature for exam purposes
Image: ghcr.io/company/production/signed-app:v1.0.0
Digest: sha256:abc123def456...
Signed by: company-ci
Timestamp: $(date -Iseconds)
-----END SIGNATURE-----
EOF

echo ""
echo "4. Creating SBOM attestation..."
cat > /tmp/sbom.spdx.json << EOF
{
  "SPDXID": "SPDXRef-DOCUMENT",
  "name": "ghcr.io/company/production/signed-app:v1.0.0",
  "spdxVersion": "SPDX-2.3",
  "creationInfo": {
    "created": "$(date -Iseconds)",
    "creators": ["Tool: company-ci", "Organization: Company Security"]
  },
  "dataLicense": "CC0-1.0",
  "documentNamespace": "https://company.com/sbom/$(uuidgen)",
  "packages": [
    {
      "SPDXID": "SPDXRef-Package-python",
      "name": "python",
      "versionInfo": "3.11.4",
      "supplier": "Organization: Python Software Foundation"
    },
    {
      "SPDXID": "SPDXRef-Package-flask",
      "name": "flask",
      "versionInfo": "2.3.3",
      "supplier": "Organization: Pallets Projects"
    }
  ]
}
EOF

echo ""
echo "Test images created:"
echo "  - ghcr.io/company/production/signed-app:v1.0.0 (signed with SBOM)"
echo "  - ghcr.io/company/production/unsigned-app:latest (unsigned)"
echo ""
echo "Note: In production, you would:"
echo "  1. Use real Cosign with private key"
echo "  2. Push to registry with cosign sign"
echo "  3. Attach SBOM with cosign attest"
echo "  4. Verify with cosign verify"