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
  region = var.aws_region
}

resource "aws_key_pair" "k8s_key" {
  key_name   = "k8s-lab-key"
  public_key = file(var.ssh_public_key_path)
}

resource "aws_vpc" "k8s_vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "k8s-vpc"
  }
}

resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.k8s_vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true
  tags = {
    Name = "k8s-public-subnet"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.k8s_vpc.id
  tags = {
    Name = "k8s-igw"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.k8s_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = {
    Name = "k8s-public-rt"
  }
}

resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

resource "aws_security_group" "nodes" {
  name        = "k8s-nodes-sg"
  vpc_id      = aws_vpc.k8s_vpc.id
  
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  ingress {
    from_port   = 6443
    to_port     = 6443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    self        = true
  }
  
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

resource "aws_instance" "master" {
  ami           = "ami-0c55b159cbfafe1f0"
  instance_type = var.master_instance_type
  subnet_id     = aws_subnet.public.id
  vpc_security_group_ids = [aws_security_group.nodes.id]
  key_name      = aws_key_pair.k8s_key.key_name
  
  root_block_device {
    volume_size = 30
    volume_type = "gp3"
  }
  
  tags = {
    Name = "k8s-master"
  }
}

resource "aws_instance" "worker1" {
  ami           = "ami-0c55b159cbfafe1f0"
  instance_type = var.worker_instance_type
  subnet_id     = aws_subnet.public.id
  vpc_security_group_ids = [aws_security_group.nodes.id]
  key_name      = aws_key_pair.k8s_key.key_name
  
  root_block_device {
    volume_size = 30
    volume_type = "gp3"
  }
  
  tags = {
    Name = "k8s-worker1"
  }
}

resource "aws_instance" "worker2" {
  ami           = "ami-0c55b159cbfafe1f0"
  instance_type = var.worker_instance_type
  subnet_id     = aws_subnet.public.id
  vpc_security_group_ids = [aws_security_group.nodes.id]
  key_name      = aws_key_pair.k8s_key.key_name
  
  root_block_device {
    volume_size = 30
    volume_type = "gp3"
  }
  
  tags = {
    Name = "k8s-worker2"
  }
}