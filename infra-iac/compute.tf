resource "aws_launch_template" "ec2_lt" {
  name_prefix   = "${var.project_name}-${var.environment}-lt"
  image_id      = var.ami_id
  instance_type = var.instance_type
  key_name      = var.key_pair_name

  network_interfaces {
    security_groups             = [aws_security_group.ec2_sg.id]
    associate_public_ip_address = false
  }

  user_data = length(var.user_data_file) > 0 && fileexists(var.user_data_file) ? base64encode(file(var.user_data_file)) : ""

  tag_specifications {
    resource_type = "instance"
    tags          = { Name = "${var.project_name}-${var.environment}-ec2" }
  }
}

resource "aws_autoscaling_group" "asg" {
  name                = "${var.project_name}-${var.environment}-asg"
  vpc_zone_identifier = [for subnet in aws_subnet.private : subnet.id]
  desired_capacity    = var.desired_capacity
  max_size            = var.max_size
  min_size            = var.min_size

  launch_template {
    id      = aws_launch_template.ec2_lt.id
    version = "$Latest"
  }

  target_group_arns         = [aws_lb_target_group.tg.arn]
  health_check_type         = "ELB"
  health_check_grace_period = 60

  tag {
    key                 = "Name"
    value               = "${var.project_name}-${var.environment}-ec2"
    propagate_at_launch = true
  }
}
