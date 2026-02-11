resource "aws_security_group" "instance_sg" {
  name        = "${var.project_name}-instance-sg"
  description = "Security group for instances"
  vpc_id      = var.vpc_id
  
  ingress {
    description = "SSH from allowed IPs"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = var.allowed_ips
  }
  
  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  ingress {
    description = "HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  ingress {
    description = "Allow all within security group"
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
    Name = "${var.project_name}-instance-sg"
  }
}

data "template_file" "user_data" {
  template = file("${path.module}/../../scripts/userdata.sh")
  
  vars = {
    project_name = var.project_name
  }
}

resource "aws_instance" "nodes" {
  count                  = var.instance_count
  ami                    = var.ami_id
  instance_type          = var.instance_type
  subnet_id              = element(var.public_subnet_ids, count.index % length(var.public_subnet_ids))
  vpc_security_group_ids = [aws_security_group.instance_sg.id]
  key_name               = var.key_name
  iam_instance_profile   = var.iam_instance_profile
  
  user_data = data.template_file.user_data.rendered
  
  root_block_device {
    volume_size = 20
    volume_type = "gp3"
    encrypted   = true
  }
  
  tags = {
    Name     = "${var.project_name}-node-${count.index + 1}"
    Role     = "node"
    NodeId   = count.index + 1
  }
  
  lifecycle {
    create_before_destroy = true
  }
}