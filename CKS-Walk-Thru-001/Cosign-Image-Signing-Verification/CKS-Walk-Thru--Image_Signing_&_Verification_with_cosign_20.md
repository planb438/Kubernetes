## Image Signing & Verification with cosign

🖼️ PART 1: Image Signing & Verification with cosign

🔧 Step 1: Install cosign
On your local machine:



curl -sSL https://github.com/sigstore/cosign/releases/latest/download/cosign-linux-amd64 \
  -o /usr/local/bin/cosign && chmod +x /usr/local/bin/cosign


Verify:



cosign version



🔐 Step 2: Generate a Key Pair
bash
CopyEdit


cosign generate-key-pair


This creates:
• cosign.key → private key

• cosign.pub → public key


Securely store these (in real world you'd use KMS or GitHub OIDC keys).

🏗 Step 3: Sign an Image (Your Own or Public)
Let's assume you pushed a test image to Docker Hub:



docker push yourname/test-app:1.0


Then sign it:



cosign sign --key cosign.key docker.io/yourname/test-app:1.0


You’ll see confirmation that cosign added a signature to the image’s metadata.

🔍 Step 4: Verify an Image
On another node or cluster:



cosign verify --key cosign.pub docker.io/yourname/test-app:1.0


✅ Output should say “Verified OK” — otherwise image integrity has been compromised.

🧪 Bonus: Use with Kubernetes Admission Controllers (Optional)
You can pair cosign with tools like Kyverno, Gatekeeper, or Sigstore Policy Controller to block unsigned or tampered images.


