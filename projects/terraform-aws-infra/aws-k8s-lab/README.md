Kubernetes Lab - AWS Infrastructure
This Terraform configuration sets up a 3-node Kubernetes lab environment on AWS with 1 master and 2 worker nodes.

Files Structure
text
aws-k8s-lab/
├── main.tf           # Main infrastructure configuration
├── variables.tf      # Input variables
├── outputs.tf        # Output values
├── terraform.tfvars  # Your specific values (optional)
├── .gitignore        # Ignore terraform files
├── master-bootstrap.sh  # Bootstrap script for master node
└── worker-bootstrap.sh  # Bootstrap script for worker nodes
Prerequisites
AWS Account with appropriate permissions

AWS CLI configured with credentials

Terraform installed (>= 1.0.0)

SSH Key Pair on your local machine:

bash
ssh-keygen -t rsa -b 4096 -f ~/.ssh/id_rsa -N ""
Resources Created
1 VPC (10.0.0.0/16)

1 Public Subnet (10.0.1.0/24)

1 Internet Gateway

1 Security Group (allows SSH 22, Kubernetes API 6443, and inter-node traffic)

AWS Key Pair (using your local SSH public key)

3 EC2 Instances:

1 Master node (t3.medium)

2 Worker nodes (t3.small)

Quick Start
1. Initialize Terraform
bash
terraform init
2. Review the plan
bash
terraform plan
3. Apply the configuration
bash
terraform apply -auto-approve
4. Get connection information
bash
terraform output
5. SSH to instances
Use the output commands or:

bash
ssh -i ~/.ssh/id_rsa ubuntu@<master-public-ip>
ssh -i ~/.ssh/id_rsa ubuntu@<worker1-public-ip>
ssh -i ~/.ssh/id_rsa ubuntu@<worker2-public-ip>
Bootstrap Kubernetes
On Master Node:
bash
# Copy the bootstrap script
scp -i ~/.ssh/id_rsa master-bootstrap.sh ubuntu@<master-public-ip>:

# SSH to master
ssh -i ~/.ssh/id_rsa ubuntu@<master-public-ip>

# Run bootstrap
sudo bash master-bootstrap.sh

# After bootstrap completes, save the kubeadm join command
On Each Worker Node:
bash
# Copy the bootstrap script
scp -i ~/.ssh/id_rsa worker-bootstrap.sh ubuntu@<worker-public-ip>:

# SSH to worker
ssh -i ~/.ssh/id_rsa ubuntu@<worker-public-ip>

# Run bootstrap
sudo bash worker-bootstrap.sh

# Join the cluster using the command from master
sudo kubeadm join <master-ip>:6443 --token <token> --discovery-token-ca-cert-hash sha256:<hash>
On Master Node After Workers Join:
bash
# Verify all nodes
kubectl get nodes

# Install CNI (required)
kubectl apply -f https://raw.githubusercontent.com/flannel-io/flannel/master/Documentation/kube-flannel.yml

# Verify pods
kubectl get pods -A
Cleanup
To destroy all resources and avoid AWS charges:

bash
terraform destroy -auto-approve
Cost Estimate
Master (t3.medium): ~$0.0416/hour (~$30/month)

Workers (t3.small x2): ~$0.0208/hour each (~$15/month each)

Total: ~$0.0832/hour (~$60/month)

Note: Destroy resources when not in use to avoid unnecessary charges.

Customization
Instance Types
Edit variables.tf to change instance types:

terraform
variable "master_instance_type" {
  default = "t3.large"  # For more resources
}

variable "worker_instance_type" {
  default = "t3.medium"  # For larger workloads
}
SSH Key Path
If your SSH key is in a different location, create terraform.tfvars:

hcl
ssh_public_key_path = "/path/to/your/public_key.pub"
Security Notes
Security group allows SSH (22) and Kubernetes API (6443) from anywhere (0.0.0.0/0)

Inter-node traffic is allowed for cluster communication

All outbound traffic is allowed

Consider restricting SSH access to your IP in production

Troubleshooting
SSH Connection Issues
bash
# Verify SSH key permissions
chmod 600 ~/.ssh/id_rsa

# Check instance status in AWS Console
Terraform Errors
bash
# Reinitialize if modules change
terraform init -upgrade

# Check AWS credentials
aws sts get-caller-identity
Kubernetes Issues
bash
# Reset kubeadm if needed
sudo kubeadm reset -f

# Check kubelet logs
sudo journalctl -u kubelet -f
Bootstrap Scripts
The bootstrap scripts only install:

containerd

kubeadm, kubelet, kubectl (master only gets kubectl)

Basic kernel configurations

No additional software, addons, or configurations are installed. You maintain full control over the cluster setup.

Support
For issues with Terraform, check the Terraform documentation.
For Kubernetes issues, refer to the Kubernetes documentation.
For AWS issues, check the AWS documentation.