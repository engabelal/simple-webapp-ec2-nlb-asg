project_name    = "simple-webapp"
environment     = "dev"
region          = "us-east-1"
vpc_cidr        = "10.0.0.0/16"
public_subnets  = ["10.0.1.0/24", "10.0.2.0/24"]
private_subnets = ["10.0.3.0/24", "10.0.4.0/24"]
azs             = ["us-east-1a", "us-east-1b"]
ami_id          = "ami-0fd2b85ee2b4dc969" # my_created_template
