#!/bin/bash

MASTER_IP=${master_ip}

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

# The actual join command will be run manually after cluster is set up
# This gives you time to get the token from master

echo "Worker node ready. To join cluster, SSH to master, get join command from /home/ubuntu/join-command.txt"
echo "Then run that command on this worker node."

# Reboot to apply all changes
reboot