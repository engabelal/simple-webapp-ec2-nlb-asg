terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.14"
    }
  }
  required_version = ">= 1.8.0"
}
provider "aws" {
  region = var.region
}

# Create VPC
resource "aws_vpc" "this" {
  cidr_block           = var.vpc_cidr # Primary CIDR block for the VPC
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "${var.project_name}-${var.environment}-vpc"
  }
}

# Create Internet Gateway (to allow public subnets to access Internet)
resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id

  tags = {
    Name = "${var.project_name}-${var.environment}-igw"
  }
}

# Create Public Subnets
resource "aws_subnet" "public" {
  count                   = length(var.public_subnets) # Number of subnets to create
  vpc_id                  = aws_vpc.this.id
  cidr_block              = var.public_subnets[count.index] # Public subnet CIDR loop
  availability_zone       = var.azs[count.index]
  map_public_ip_on_launch = false # Auto-assign public IPs

  tags = {
    Name = "${var.project_name}-${var.environment}-public-${count.index + 1}"
  }
}

# Create Private Subnets
resource "aws_subnet" "private" {
  count             = length(var.private_subnets) # Number of subnets to create
  vpc_id            = aws_vpc.this.id
  cidr_block        = var.private_subnets[count.index]
  availability_zone = var.azs[count.index]

  tags = {
    Name = "${var.project_name}-${var.environment}-private-${count.index + 1}"
  }
}

# Create Public Route Table
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.this.id
  }

  tags = {
    Name = "${var.project_name}-${var.environment}-public-rt"
  }
}

# Associate Public Subnets with Public Route Table
resource "aws_security_group" "ec2_sg" {
  name        = "${var.project_name}-${var.environment}-ec2-sg"
  description = "Allow web traffic from NLB and intra-SG"
  vpc_id      = aws_vpc.this.id

  # allow HTTP from anywhere (for NLB)
  ingress {
    description = "Allow HTTP from anywhere (for NLB)"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # allow instances in this SG to talk to each other on port 80
  ingress {
    description = "Allow inbound from same security group"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    self        = true # <--- allows sg to itself to make resources talk to each other
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1" # all protocols
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-${var.environment}-ec2-sg"
  }
}
# Create Network Load Balancer
resource "aws_lb" "nlb" {
  name               = "${var.project_name}-${var.environment}-nlb"
  internal           = false
  load_balancer_type = "network"
  subnets            = [for subnet in aws_subnet.public : subnet.id] # if single subnet, it was aws_subnet.public[*].id

  tags = {
    Name = "${var.project_name}-${var.environment}-nlb"
  }
}

# Create Target Group for NLB
resource "aws_lb_target_group" "tg" {
  name     = "${var.project_name}-${var.environment}-tg"
  port     = 80
  protocol = "TCP"
  vpc_id   = aws_vpc.this.id

  health_check {
    protocol            = "TCP"
    healthy_threshold   = 3
    unhealthy_threshold = 3
    interval            = 10
  }
}
# Create Listener for NLB
resource "aws_lb_listener" "nlb_listener" {
  load_balancer_arn = aws_lb.nlb.arn
  port              = 80
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg.arn
  }
}

# EC2 Launch Template + Auto Scaling Group
resource "aws_launch_template" "ec2_lt" {
  name_prefix   = "${var.project_name}-${var.environment}-lt"
  image_id      = var.ami_id
  instance_type = var.instance_type

  network_interfaces {
    security_groups = [aws_security_group.ec2_sg.id]
  }

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "${var.project_name}-${var.environment}-ec2"
    }
  }
}
resource "aws_autoscaling_group" "asg" {
  vpc_zone_identifier = [for subnet in aws_subnet.private : subnet.id]
  desired_capacity    = var.desired_capacity
  max_size            = var.max_size
  min_size            = var.min_size

  launch_template {
    id      = aws_launch_template.ec2_lt.id
    version = "$Latest"
  }

  target_group_arns = [aws_lb_target_group.tg.arn]

  tag {
    key                 = "Name"
    value               = "${var.project_name}-${var.environment}-ec2"
    propagate_at_launch = true
  }
}
