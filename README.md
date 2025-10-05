# Simple Web App on AWS EC2 Auto Scaling with NLB

A production-ready AWS infrastructure deployed with Terraform featuring EC2 Auto Scaling, Network Load Balancer, and multi-AZ architecture.

## 🏗️ Architecture Diagram

```
                                ┌─────────────┐
                                │   Internet  │
                                └──────┬──────┘
                                       │
                ┌──────────────────────┴──────────────────────┐
                │                                              │
┌───────────────┴────────────────────────────────────────────┴───────────────┐
│                          AWS VPC (10.0.0.0/16)                              │
│                                                                              │
│  ┌────────────────────────────────────────────────────────────────────┐    │
│  │                        Internet Gateway                             │    │
│  └────────────────────────────┬───────────────────────────────────────┘    │
│                               │                                             │
│  ┌────────────────────────────┴───────────────────────────────────────┐    │
│  │                    Public Subnets (Multi-AZ)                        │    │
│  │  ┌──────────────────────┐         ┌──────────────────────┐         │    │
│  │  │  Public Subnet 1     │         │  Public Subnet 2     │         │    │
│  │  │  10.0.1.0/24         │         │  10.0.2.0/24         │         │    │
│  │  │  (eu-north-1a)       │         │  (eu-north-1b)       │         │    │
│  │  └──────────────────────┘         └──────────────────────┘         │    │
│  └────────────────────────────┬───────────────────────────────────────┘    │
│                               │                                             │
│  ┌────────────────────────────┴───────────────────────────────────────┐    │
│  │          Network Load Balancer (Internet-facing)                    │    │
│  │                     Port 80 (TCP)                                   │    │
│  └────────────────────────────┬───────────────────────────────────────┘    │
│                               │                                             │
│  ┌──────────────┐             │                                             │
│  │ NAT Gateway  │◄────────────┼─────────────────┐                          │
│  │ (Public-1)   │             │                 │                          │
│  └──────────────┘             │                 │                          │
│                               │                 │                          │
│  ┌────────────────────────────┴─────────────────┼──────────────────────┐   │
│  │                Private Subnets (Multi-AZ)    │                      │   │
│  │  ┌──────────────────────┐   ┌────────────────┴────────┐             │   │
│  │  │  Private Subnet 1    │   │  Private Subnet 2       │             │   │
│  │  │  10.0.3.0/24         │   │  10.0.4.0/24            │             │   │
│  │  │  (eu-north-1a)       │   │  (eu-north-1b)          │             │   │
│  │  │  ┌────────────┐      │   │  ┌────────────┐         │             │   │
│  │  │  │    EC2     │      │   │  │    EC2     │         │             │   │
│  │  │  │  Apache    │──────┼───┼──│  Apache    │         │             │   │
│  │  │  │  Port 80   │      │   │  │  Port 80   │         │             │   │
│  │  │  └────────────┘      │   │  └────────────┘         │             │   │
│  │  └──────────────────────┘   └─────────────────────────┘             │   │
│  └────────────────────────────────────────────────────────────────────┘   │
│                                                                              │
│  ┌────────────────────────────────────────────────────────────────────┐    │
│  │         Auto Scaling Group (Min: 2, Desired: 2, Max: 4)            │    │
│  └────────────────────────────────────────────────────────────────────┘    │
│                                                                              │
│  ┌────────────────────────────────────────────────────────────────────┐    │
│  │  Security Group: Port 80 (0.0.0.0/0 + Self) | Outbound: All        │    │
│  └────────────────────────────────────────────────────────────────────┘    │
└──────────────────────────────────────────────────────────────────────────────┘
```

### Traffic Flow
1. **User Request** → Internet → Internet Gateway → NLB (Public Subnets)
2. **NLB** → Target Group → EC2 Instances (Private Subnets)
3. **EC2 Response** → NLB → Internet Gateway → User
4. **EC2 Outbound** → NAT Gateway → Internet Gateway → Internet

## 📦 Components

### Networking
- **VPC** - Isolated network environment
- **Public Subnets** (Multi-AZ) - Host NLB and NAT Gateway
- **Private Subnets** (Multi-AZ) - Host EC2 instances
- **Internet Gateway** - Public internet access
- **NAT Gateway** - Outbound internet for private instances
- **Route Tables** - Traffic routing configuration

### Compute
- **Launch Template** - EC2 configuration with user data
- **Auto Scaling Group** - Maintains desired instance count
- **EC2 Instances** - Apache web servers with demo page

### Load Balancing
- **Network Load Balancer** - Layer 4 load balancing
- **Target Group** - Health checks and routing
- **Listener** - Port 80 TCP traffic forwarding

### Security
- **Security Group** - Firewall rules for EC2 instances
  - Inbound: Port 80 from anywhere
  - Inbound: Port 80 from same SG
  - Outbound: All traffic

## 📁 Project Structure

```
.
├── infra-iac/
│   ├── compute.tf          # Launch Template & ASG
│   ├── loadbalancer.tf     # NLB, Target Group, Listener
│   ├── networking.tf       # VPC, Subnets, IGW, NAT
│   ├── security.tf         # Security Groups
│   ├── variables.tf        # Input variables
│   ├── outputs.tf          # Output values
│   ├── provider.tf         # AWS provider config
│   └── main.tf             # Main configuration
├── envs/
│   ├── dev.tfvars          # Development environment
│   └── prod.tfvars         # Production environment
├── userdata/
│   └── bootstrap.sh        # EC2 initialization script
├── scripts/
│   └── start.sh            # Deployment helper script
├── images/
│   └── result.png          # Web app screenshot
└── README.md
```

## 📸 Demo Screenshot

![Web Application Result](images/result.png)

*The web application displays instance metadata (ID, AZ, Region) and infrastructure components deployed via Terraform.*

## 🚀 Deployment

### Prerequisites
- Terraform >= 1.8.0
- AWS CLI configured
- EC2 Key Pair (optional, for SSH access)

### Multi-Environment Support

This project supports multiple environments (dev/prod) using separate `.tfvars` files:
- `envs/dev.tfvars` - Development environment
- `envs/prod.tfvars` - Production environment

### Deploy to Development

```bash
# Navigate to infrastructure directory
cd infra-iac

# Initialize Terraform
terraform init

# Plan deployment
terraform plan -var-file="../envs/dev.tfvars"

# Apply changes
terraform apply -var-file="../envs/dev.tfvars"

# Get outputs
terraform output nlb_dns_name
```

### Deploy to Production

```bash
# Navigate to infrastructure directory
cd infra-iac

# Initialize Terraform (if not done)
terraform init

# Plan deployment
terraform plan -var-file="../envs/prod.tfvars"

# Apply changes
terraform apply -var-file="../envs/prod.tfvars"

# Get outputs
terraform output nlb_dns_name
```

### Access the Application

```bash
# Get the NLB DNS name
NLB_DNS=$(terraform output -raw nlb_dns_name)

# Test the application
curl http://$NLB_DNS

# Or open in browser
echo "http://$NLB_DNS"
```

## ⚙️ Configuration

### Environment Variables (dev.tfvars)

```hcl
project_name    = "simple-webapp"
environment     = "dev"
region          = "eu-north-1"
vpc_cidr        = "10.0.0.0/16"
public_subnets  = ["10.0.1.0/24", "10.0.2.0/24"]
private_subnets = ["10.0.3.0/24", "10.0.4.0/24"]
azs             = ["eu-north-1a", "eu-north-1b"]
ami_id          = "ami-04c08fd8aa14af291"  # Amazon Linux 2023
instance_type   = "t3.micro"
desired_capacity = 2
min_size        = 2
max_size        = 4
key_pair_name   = "your-key-pair"  # Optional
user_data_file  = "../userdata/bootstrap.sh"
```

### Key Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `project_name` | Resource name prefix | - |
| `environment` | Environment (dev/prod) | - |
| `region` | AWS region | us-east-1 |
| `vpc_cidr` | VPC CIDR block | 10.0.0.0/16 |
| `instance_type` | EC2 instance type | t3.micro |
| `desired_capacity` | Desired ASG instances | 2 |
| `min_size` | Minimum ASG instances | 2 |
| `max_size` | Maximum ASG instances | 4 |

## 🔍 Outputs

- **nlb_dns_name** - Network Load Balancer DNS endpoint

## 🧪 Testing

### Verify Load Balancing
```bash
# Multiple requests should show different instance IDs
for i in {1..10}; do
  curl http://<nlb-dns-name> | grep "Instance ID"
done
```

### Check Auto Scaling
```bash
# Terminate an instance and watch ASG replace it
aws ec2 terminate-instances --instance-ids <instance-id>
aws autoscaling describe-auto-scaling-groups --auto-scaling-group-names <asg-name>
```

## 🧹 Cleanup

### Destroy Development Environment
```bash
cd infra-iac
terraform destroy -var-file="../envs/dev.tfvars"
```

### Destroy Production Environment
```bash
cd infra-iac
terraform destroy -var-file="../envs/prod.tfvars"
```

## 📊 Cost Estimation

**Approximate monthly cost (us-east-1):**
- 2x t3.micro instances: ~$15
- Network Load Balancer: ~$16
- NAT Gateway: ~$32
- Data transfer: Variable
- **Total: ~$63/month**

## 🔒 Security Best Practices

✅ EC2 instances in private subnets  
✅ No public IPs on instances  
✅ Security groups with minimal permissions  
✅ NAT Gateway for outbound traffic only  
✅ Multi-AZ deployment for high availability  

## 🛠️ Customization

### Change Instance Count
Edit `envs/dev.tfvars`:
```hcl
desired_capacity = 3
min_size        = 2
max_size        = 6
```

### Use Different AMI
```hcl
ami_id = "ami-xxxxxxxxx"  # Your custom AMI
```

### Modify User Data
Edit `userdata/bootstrap.sh` to customize instance initialization.

## 📝 Notes

- The bootstrap script installs Apache and serves a demo page
- Instance metadata (ID, AZ, Region) is displayed on the web page
- Health checks use TCP on port 80
- Auto Scaling maintains the desired instance count automatically

## 🤝 Contributing

Feel free to submit issues or pull requests for improvements.

## 📄 License

MIT License - See LICENSE file for details.

## 👤 Author

**ABCloudOps**  
Infrastructure as Code Demo Project

---

**Built with:** Terraform | AWS | Apache | Bash
