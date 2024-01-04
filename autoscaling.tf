resource "aws_launch_template" "launch_template" {
  name          = "${var.project}-template"
  image_id      = var.image_id
  instance_type = var.instance_type
  key_name  = var.key_name != null ? var.key_name : null
  user_data = filebase64("./ec2-init.sh")
  metadata_options {
    http_tokens = "required"
    http_endpoint = "enabled"
  }
  block_device_mappings {
    device_name = "/dev/sda1"

    ebs {
      volume_size = 150
      delete_on_termination = true
      encrypted             = true
    }
  }




iam_instance_profile {
   name = "var.iam_role"
  }

  # vpc_security_group_ids = var.vpc_security_group_ids

  # Note: If using 'network_interfaces' like below then DON't user 'vpc_security_group_ids' separately. use 'security_groups' under network_interfaces
  network_interfaces {
    associate_public_ip_address = false
    security_groups             = var.vpc_security_group_ids
  }

  tag_specifications {
    resource_type = "instance"
    tags          = merge({ "ResourceName" = "${var.project}-template" }, local.tags)
  }

}

resource "aws_autoscaling_group" "asg_group" {

  name                      = "${var.project}-asg"
  max_size                  = var.max_size
  min_size                  = var.min_size
  desired_capacity          = var.desired_capacity
  health_check_grace_period = 300
  health_check_type         = var.asg_health_check_type #"ELB" or default EC2
  #availability_zones = var.availability_zones #["us-east-1a"]
  vpc_zone_identifier = var.subnets
  # target_group_arns   = [module.aws_lb.lb_tg_arn] #var.target_group_arns

  tags = [
    {
      key = "Name"
      value = "${var.project}"
      propagate_at_launch = true
    }
  ]


  enabled_metrics = [
    "GroupMinSize",
    "GroupMaxSize",
    "GroupDesiredCapacity",
    "GroupInServiceInstances",
    "GroupTotalInstances"
  ]

  metrics_granularity = "1Minute"

  launch_template {
    id      = aws_launch_template.launch_template.id
    version = aws_launch_template.launch_template.latest_version #"$Latest"
  }
}

# scale up policy
resource "aws_autoscaling_policy" "scale_up" {
  name                   = "${var.project}-asg-scale-up"
  autoscaling_group_name = aws_autoscaling_group.asg_group.name
  adjustment_type        = "ChangeInCapacity"
  scaling_adjustment     = "1" #increasing instance by 1 
  cooldown               = "300"
  policy_type            = "SimpleScaling"
}

# scale down policy
resource "aws_autoscaling_policy" "scale_down" {
  name                   = "${var.project}-asg-scale-down"
  autoscaling_group_name = aws_autoscaling_group.asg_group.name
  adjustment_type        = "ChangeInCapacity"
  scaling_adjustment     = "-1" # decreasing instance by 1 
  cooldown               = "300"
  policy_type            = "SimpleScaling"
}
