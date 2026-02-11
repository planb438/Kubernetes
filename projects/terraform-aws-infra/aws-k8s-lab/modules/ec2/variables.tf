variable "project_name" {
  type = string
}

variable "instance_count" {
  type    = number
  default = 3
}

variable "instance_type" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "public_subnet_ids" {
  type = list(string)
}

variable "key_name" {
  type = string
}

variable "iam_instance_profile" {
  type = string
}

variable "allowed_ips" {
  type    = list(string)
  default = ["0.0.0.0/0"]
}

variable "ami_id" {
  type    = string
  default = "ami-0c02fb55956c7d316"
}