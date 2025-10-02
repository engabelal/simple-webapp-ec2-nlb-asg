# Project name (used as prefix for resource names)
variable "project_name" {
  description = "Project name prefix (e.g., simple-webapp)"
  type        = string
}

# Environment (dev, test, prod)
variable "environment" {
  description = "Environment name"
  type        = string
}

# AWS region to deploy resources
variable "region" {
  description = "AWS Region"
  type        = string
  default     = "us-east-1"
}

# CIDR block for the VPC
variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

# Public subnet CIDR ranges
variable "public_subnets" {
  description = "List of public subnet CIDRs"
  type        = list(string)
}

# Private subnet CIDR ranges
variable "private_subnets" {
  description = "List of private subnet CIDRs"
  type        = list(string)
}

# Availability Zones to use
variable "azs" {
  description = "List of Availability Zones"
  type        = list(string)
}

# EC2 instance type for Auto Scaling Group
variable "instance_type" {
  description = "EC2 instance type (e.g., t3.micro)"
  type        = string
  default     = "t3.micro"
}

# Desired number of instances in ASG
variable "desired_capacity" {
  description = "Desired number of EC2 instances in ASG"
  type        = number
  default     = 2
}

# Minimum number of instances in ASG
variable "min_size" {
  description = "Minimum number of EC2 instances in ASG"
  type        = number
  default     = 2
}

# Maximum number of instances in ASG
variable "max_size" {
  description = "Maximum number of EC2 instances in ASG"
  type        = number
  default     = 4
}
variable "ami_id" {
  description = "AMI ID for EC2 instances"
  type        = string
}
variable "key_pair_name" {
  description = "EC2 Key Pair name to use for SSH access"
  type        = string
  default     = ""
}

# Optional path to a user-data script file. Leave empty to skip user-data.
variable "user_data_file" {
  description = "Path to user-data file (relative to terraform root). Leave empty to disable."
  type        = string
  default     = ""
}
