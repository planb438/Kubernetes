output "ssh_master" {
  value = "ssh -i k8s-lab-key.pem ubuntu@${aws_instance.master.public_ip}"
}

output "ssh_workers" {
  value = [
    for ip in aws_instance.workers[*].public_ip :
    "ssh -i k8s-lab-key.pem ubuntu@${ip}"
  ]
}
