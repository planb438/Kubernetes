output "vpc_id" {
  description = "ID of the created VPC"
  value       = module.vpc.vpc_id
}

output "public_subnet_ids" {
  description = "IDs of public subnets"
  value       = module.vpc.public_subnet_ids
}

output "instance_public_ips" {
  description = "Public IP addresses of instances"
  value       = module.ec2_cluster.instance_public_ips
}

output "instance_ids" {
  description = "IDs of the created instances"
  value       = module.ec2_cluster.instance_ids
}

output "security_group_id" {
  description = "ID of the security group"
  value       = module.ec2_cluster.security_group_id
}

output "s3_bucket_name" {
  description = "Name of the S3 bucket for Terraform state"
  value       = try(aws_s3_bucket.terraform_state.bucket, "Bucket not created in this run")
}

output "iam_role_arn" {
  description = "ARN of the IAM role for instances"
  value       = module.iam.instance_role_arn
}