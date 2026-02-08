terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region  = "us-east-1"
}

# Use default VPC
data "aws_vpc" "default" {
  default = true
}

# Get ALL subnets in default VPC
data "aws_subnets" "all" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

# Security Group for MicroK8s cluster
resource "aws_security_group" "microk8s" {
  name        = "microk8s-cluster-sg"
  description = "Security group for MicroK8s cluster"
  vpc_id      = data.aws_vpc.default.id

  # SSH access
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Kubernetes API server
  ingress {
    from_port   = 6443
    to_port     = 6443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # NodePort services
  ingress {
    from_port   = 30000
    to_port     = 32767
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # MicroK8s cluster communication
  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    self        = true
  }

  # All outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "microk8s-cluster"
  }
}

# SSH key pair
resource "aws_key_pair" "microk8s" {
  key_name   = "microk8s-key"
  public_key = file("~/.ssh/id_rsa.pub")
}

# Get latest Ubuntu 22.04 LTS AMI
data "aws_ami" "ubuntu_2204" {
  most_recent = true
  owners      = ["099720109477"]
  
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }
  
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# Master Node - Use t2.micro for guaranteed availability
resource "aws_instance" "master" {
  ami                    = data.aws_ami.ubuntu_2204.id
  instance_type          = "t3.micro"  # Use t3.micro for wider availability
  key_name               = aws_key_pair.microk8s.key_name
  vpc_security_group_ids = [aws_security_group.microk8s.id]
  
  # Don't specify subnet - let AWS choose available AZ
  # Or use availability_zone parameter if needed
  
  user_data = file("${path.module}/user-data/master.sh")

  root_block_device {
    volume_size = 8  # Minimum for Ubuntu
    volume_type = "gp3"
  }

  tags = {
    Name  = "microk8s-master"
    Role  = "master"
    Owner = "terraform"
  }
}

# Worker Nodes (2 instances) - Use t2.micro
resource "aws_instance" "workers" {
  count = 2

  ami                    = data.aws_ami.ubuntu_2204.id
  instance_type          = "t3.micro"  # Use t2.micro for wider availability
  key_name               = aws_key_pair.microk8s.key_name
  vpc_security_group_ids = [aws_security_group.microk8s.id]
  
  # Don't specify subnet - let AWS choose
  # Add depends_on to ensure master is created first
  depends_on = [aws_instance.master]

  user_data = templatefile("${path.module}/user-data/worker.sh", {
    master_ip = aws_instance.master.private_ip
  })

  root_block_device {
    volume_size = 8
    volume_type = "gp3"
  }

  tags = {
    Name  = "microk8s-worker-${count.index + 1}"
    Role  = "worker"
    Owner = "terraform"
  }
}

# Elastic IP for master (optional)
resource "aws_eip" "master" {
  instance = aws_instance.master.id
  domain   = "vpc"

  tags = {
    Name = "microk8s-master-eip"
  }
}