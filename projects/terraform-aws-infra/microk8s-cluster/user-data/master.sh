#!/bin/bash

# Update system
apt-get update
apt-get upgrade -y

# Install MicroK8s
snap install microk8s --classic --channel=1.28/stable

# Add current user to microk8s group
usermod -a -G microk8s ubuntu
chown -f -R ubuntu ~/.kube

# Wait for MicroK8s to initialize
sleep 30

# Enable addons (choose based on your needs)
microk8s enable dns
microk8s enable dashboard
microk8s enable storage
microk8s enable registry

# Get join token and store it
microk8s add-node --token-ttl 3600 | grep "microk8s join" > /home/ubuntu/join-command.txt

# Create alias for kubectl
echo "alias kubectl='microk8s kubectl'" >> /home/ubuntu/.bashrc

# Configure kubectl for non-root access
mkdir -p /home/ubuntu/.kube
microk8s config > /home/ubuntu/.kube/config
chown -R ubuntu:ubuntu /home/ubuntu/.kube

# Install common tools
apt-get install -y curl git

# Reboot to apply all changes
reboot