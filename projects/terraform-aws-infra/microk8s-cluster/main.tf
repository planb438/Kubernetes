terraform {
  required_version = ">= 1.0.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
  
  default_tags {
    tags = {
      Project     = "k8s-lab-1master-2workers"
      Environment = "training"
      ManagedBy   = "Terraform"
    }
  }
}

# Simple VPC for lab (cost-effective)
resource "aws_vpc" "k8s_lab" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true
  
  tags = {
    Name = "k8s-lab-vpc"
  }
}

# Single public subnet (simpler, cheaper)
resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.k8s_lab.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "us-east-1a"
  
  tags = {
    Name = "k8s-lab-public-subnet"
    "kubernetes.io/cluster/k8s-lab" = "shared"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.k8s_lab.id
  
  tags = {
    Name = "k8s-lab-igw"
  }
}

# Route table
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.k8s_lab.id
  
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  
  tags = {
    Name = "k8s-lab-public-rt"
  }
}

resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

# Single Security Group for all nodes (simpler)
resource "aws_security_group" "k8s_nodes" {
  name        = "k8s-nodes-sg"
  description = "Security group for all K8s nodes"
  vpc_id      = aws_vpc.k8s_lab.id
  
  # SSH access
  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  # Kubernetes API Server
  ingress {
    description = "Kubernetes API Server"
    from_port   = 6443
    to_port     = 6443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  # NodePort Services
  ingress {
    description = "NodePort Services"
    from_port   = 30000
    to_port     = 32767
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  # All traffic between nodes (for CNI, etcd if we add it later)
  ingress {
    description = "All traffic between nodes"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    self        = true
  }
  
  # Egress - allow all outbound
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  tags = {
    Name = "k8s-nodes-sg"
  }
}

# Master Node (t3.medium - needs more RAM for control plane)
resource "aws_instance" "master" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t3.medium"
  
  subnet_id              = aws_subnet.public.id
  vpc_security_group_ids = [aws_security_group.k8s_nodes.id]
  key_name               = aws_key_pair.k8s_key.key_name
  
  root_block_device {
    volume_size = 30
    volume_type = "gp3"
    encrypted   = true
  }
  
  tags = {
    Name = "k8s-master"
    Role = "control-plane"
  }
  
  user_data = file("${path.module}/scripts/master-init.sh")
  
  # Ensure we get a public IP
  associate_public_ip_address = true
}

# Worker Nodes (t3.small - can be smaller for workloads)
resource "aws_instance" "workers" {
  count         = 2
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t3.small"  # Smaller to save costs
  
  subnet_id              = aws_subnet.public.id
  vpc_security_group_ids = [aws_security_group.k8s_nodes.id]
  key_name               = aws_key_pair.k8s_key.key_name
  
  root_block_device {
    volume_size = 30
    volume_type = "gp3"
    encrypted   = true
  }
  
  tags = {
    Name = "k8s-worker-${count.index + 1}"
    Role = "worker"
  }
  
  user_data = file("${path.module}/scripts/worker-init.sh")
  
  associate_public_ip_address = true
  
  # Optional: Use spot instances for even more savings
  # instance_market_options {
  #   market_type = "spot"
  #   spot_options {
  #     max_price = "0.01"  # Max bid price
  #   }
  # }
}

# SSH Key Pair
resource "aws_key_pair" "k8s_key" {
  key_name   = "k8s-lab-key"
  public_key = file("~/.ssh/id_rsa.pub")
}

# Get Ubuntu 22.04 AMI
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical
  
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }
  
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# Output useful information
output "master_public_ip" {
  value       = aws_instance.master.public_ip
  description = "Master node public IP for SSH access"
}

output "worker_public_ips" {
  value       = aws_instance.workers[*].public_ip
  description = "Worker nodes public IPs"
}

output "ssh_command" {
  value = "ssh -i ~/.ssh/id_rsa ubuntu@${aws_instance.master.public_ip}"
}

output "kubeadm_init_command" {
  value = "ssh -i ~/.ssh/id_rsa ubuntu@${aws_instance.master.public_ip} 'sudo kubeadm init --pod-network-cidr=10.244.0.0/16'"
}
