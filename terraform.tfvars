# NOTE : follow the instructions in readme.md

# Common
project = {}
createdby = "terraform"

# General 
aws_region = "us-east-1"

# Launch Template

image_id               = ""
instance_type          = ""
key_name               = ""
vpc_security_group_ids = [""]
iam_role = [""]



# Auto Scaling
max_size              = 3
min_size              = 3
desired_capacity      = 3
asg_health_check_type = "EC2"
target_group_arns     = []
subnets = ["subnet-abc", "subnet-def","subnet-xyz"]