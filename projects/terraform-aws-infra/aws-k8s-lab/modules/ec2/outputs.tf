output "instance_ids" {
  value = aws_instance.nodes[*].id
}

output "instance_public_ips" {
  value = aws_instance.nodes[*].public_ip
}

output "security_group_id" {
  value = aws_security_group.instance_sg.id
}