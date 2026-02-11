output "ssh_key_name" {
  value = aws_key_pair.k8s_key.key_name
}

output "master_public_ip" {
  value = aws_instance.master.public_ip
}

output "master_private_ip" {
  value = aws_instance.master.private_ip
}

output "worker1_public_ip" {
  value = aws_instance.worker1.public_ip
}

output "worker1_private_ip" {
  value = aws_instance.worker1.private_ip
}

output "worker2_public_ip" {
  value = aws_instance.worker2.public_ip
}

output "worker2_private_ip" {
  value = aws_instance.worker2.private_ip
}

output "ssh_commands" {
  value = <<-EOT
    ssh -i ~/.ssh/id_rsa ubuntu@${aws_instance.master.public_ip}
    ssh -i ~/.ssh/id_rsa ubuntu@${aws_instance.worker1.public_ip}
    ssh -i ~/.ssh/id_rsa ubuntu@${aws_instance.worker2.public_ip}
  EOT
}