output "master_public_ip" {
  description = "Public IP of the master node"
  value       = aws_eip.master.public_ip
}

output "master_private_ip" {
  description = "Private IP of the master node"
  value       = aws_instance.master.private_ip
}

output "worker_public_ips" {
  description = "Public IPs of worker nodes"
  value       = aws_instance.workers[*].public_ip
}

output "ssh_command" {
  description = "SSH command to connect to master"
  value       = "ssh -i ~/.ssh/id_rsa ubuntu@${aws_eip.master.public_ip}"
}

output "kubectl_config" {
  description = "Command to configure kubectl locally"
  value       = "ssh -i ~/.ssh/id_rsa ubuntu@${aws_eip.master.public_ip} 'microk8s config' > ~/.kube/config"
}