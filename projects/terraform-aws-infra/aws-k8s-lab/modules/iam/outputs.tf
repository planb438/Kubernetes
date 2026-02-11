output "instance_role_arn" {
  value = aws_iam_role.instance_role.arn
}

output "instance_profile_name" {
  value = aws_iam_instance_profile.instance_profile.name
}