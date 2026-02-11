#!/bin/bash

# Update system
yum update -y

# Install basic packages
yum install -y \
    curl \
    wget \
    git \
    unzip \
    jq \
    htop \
    ncdu \
    telnet \
    net-tools \
    bind-utils \
    nfs-utils \
    docker

# Start and enable Docker
systemctl start docker
systemctl enable docker

# Add ec2-user to docker group
usermod -aG docker ec2-user

# Install AWS CLI v2
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
./aws/install

# Clean up
rm -rf awscliv2.zip aws/

# Create custom motd
cat > /etc/motd << EOF
=============================================
Welcome to ${project_name} Node
=============================================
Instance ID: $(curl -s http://169.254.169.254/latest/meta-data/instance-id)
Region: $(curl -s http://169.254.169.254/latest/meta-data/placement/region)
=============================================
EOF

# Create scripts directory
mkdir -p /opt/scripts

# Create basic monitoring script
cat > /opt/scripts/check-system.sh << 'EOF'
#!/bin/bash
echo "=== System Check ==="
echo "Uptime: $(uptime)"
echo "Load Average: $(cat /proc/loadavg)"
echo "Memory Usage:"
free -h
echo "Disk Usage:"
df -h /
echo "Docker Status:"
systemctl is-active docker
EOF

chmod +x /opt/scripts/check-system.sh

echo "User data script completed at $(date)" >> /var/log/user-data.log