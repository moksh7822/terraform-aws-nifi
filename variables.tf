
# Tags
variable "project" {}
variable "createdby" {}
# General 
variable "aws_region" {}



# Launch Template

variable "image_id" {}
variable "instance_type" {}
variable "key_name" {}
variable "vpc_security_group_ids" {}
variable "iam_role" {}

# Auto Scaling
variable "max_size" {}
variable "min_size" {}
variable "desired_capacity" {}
variable "asg_health_check_type" {}
variable "target_group_arns" {}
variable "subnets" {}
