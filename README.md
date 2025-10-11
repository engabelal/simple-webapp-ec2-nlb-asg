# 🚀 Simple Web App on AWS EC2 Auto Scaling with NLB

Production-ready AWS infrastructure with EC2 Auto Scaling, Network Load Balancer, and **multi-AZ high availability**. Built with Terraform.

![Terraform](https://img.shields.io/badge/Terraform-1.8+-7B42BC?style=for-the-badge&logo=terraform&logoColor=white)
![AWS](https://img.shields.io/badge/AWS-EC2-FF9900?style=for-the-badge&logo=amazon-aws&logoColor=white)
![Node.js](https://img.shields.io/badge/Node.js-20-green?style=for-the-badge&logo=node.js&logoColor=white)
![Express](https://img.shields.io/badge/Express-4.18-000000?style=for-the-badge&logo=express&logoColor=white)
![Bash](https://img.shields.io/badge/Bash-4EAA25?style=for-the-badge&logo=gnubash&logoColor=white)

---

## ⚡ Quick Start

```bash
# 1. Clone repository
git clone https://github.com/engabelal/simple-webapp-ec2-nlb-asg.git
cd simple-webapp-ec2-nlb-asg/infra-iac

# 2. Initialize Terraform
terraform init

# 3. Deploy to dev
terraform apply -var-file="../envs/dev.tfvars"

# 4. Get NLB URL
terraform output nlb_dns_name
```

---

## 🎯 Key Features

| Feature | Description |
|---------|-------------|
| 🏗️ **Multi-AZ Architecture** | 2 Availability Zones for high availability |
| ⚡ **Auto Scaling** | Min: 2, Desired: 2, Max: 4 instances |
| 🔄 **Network Load Balancer** | Layer 4 TCP load balancing |
| 🔒 **Private Subnets** | EC2 instances isolated from internet |
| 🌐 **NAT Gateway per AZ** | Redundant outbound internet access |
| 📦 **Multi-Environment** | Separate dev/prod configurations |
| 🛡️ **Security Groups** | Minimal permissions, port 3000 only |

---

## 📊 Infrastructure Metrics

| Component | Count | Configuration |
|-----------|-------|---------------|
| **Availability Zones** | 2 | eu-north-1a, eu-north-1b |
| **Public Subnets** | 2 | 10.0.1.0/24, 10.0.2.0/24 |
| **Private Subnets** | 2 | 10.0.3.0/24, 10.0.4.0/24 |
| **NAT Gateways** | 2 | One per AZ (high availability) |
| **EC2 Instances** | 2-4 | Auto Scaling based on demand |
| **Load Balancer** | 1 | Network Load Balancer (NLB) |

---

## 📸 Screenshots

### Web Application
![Web Application Result](images/result.png)
*Node.js/Express server displaying instance metadata (ID, AZ, Region) and infrastructure components*

---

## 🏗️ Architecture

```
                    ┌─────────────┐
                    │   Internet  │
                    └──────┬──────┘
                           │
        ┌──────────────────┴──────────────────┐
        │                                     │
┌───────┴─────────────────────────────────────┴───────┐
│              AWS VPC (10.0.0.0/16)                  │
│                                                      │
│  ┌────────────────────────────────────────────┐    │
│  │          Internet Gateway                  │    │
│  └────────────────┬───────────────────────────┘    │
│                   │                                 │
│  ┌────────────────┴───────────────────────────┐    │
│  │      Public Subnets (Multi-AZ)             │    │
│  │  ┌──────────────┐    ┌──────────────┐     │    │
│  │  │ Public-1     │    │ Public-2     │     │    │
│  │  │ 10.0.1.0/24  │    │ 10.0.2.0/24  │     │    │
│  │  │ (AZ-1a)      │    │ (AZ-1b)      │     │    │
│  │  │              │    │              │     │    │
│  │  │ ┌──────────┐ │    │ ┌──────────┐ │     │    │
│  │  │ │ NAT GW 1 │ │    │ │ NAT GW 2 │ │     │    │
│  │  │ └──────────┘ │    │ └──────────┘ │     │    │
│  │  └──────────────┘    └──────────────┘     │    │
│  └────────────────┬───────────────────────────┘    │
│                   │                                 │
│  ┌────────────────┴───────────────────────────┐    │
│  │   Network Load Balancer (Internet-facing)  │    │
│  │            Port 3000 (TCP)                 │    │
│  └────────────────┬───────────────────────────┘    │
│                   │                                 │
│  ┌────────────────┴───────────────────────────┐    │
│  │      Private Subnets (Multi-AZ)            │    │
│  │  ┌──────────────┐    ┌──────────────┐     │    │
│  │  │ Private-1    │    │ Private-2    │     │    │
│  │  │ 10.0.3.0/24  │    │ 10.0.4.0/24  │     │    │
│  │  │ (AZ-1a)      │    │ (AZ-1b)      │     │    │
│  │  │              │    │              │     │    │
│  │  │ ┌──────────┐ │    │ ┌──────────┐ │     │    │
│  │  │ │   EC2    │ │    │ │   EC2    │ │     │    │
│  │  │ │ Node.js  │ │    │ │ Node.js  │ │     │    │
│  │  │ │ Port 3000│ │    │ │ Port 3000│ │     │    │
│  │  │ └──────────┘ │    │ └──────────┘ │     │    │
│  │  └──────┬───────┘    └──────┬───────┘     │    │
│  │         │                   │              │    │
│  │         └───────────┬───────┘              │    │
│  │                     │                      │    │
│  │         ┌───────────┴───────────┐          │    │
│  │         │   Auto Scaling Group  │          │    │
│  │         │  Min: 2 | Max: 4      │          │    │
│  │         └───────────────────────┘          │    │
│  └────────────────────────────────────────────┘    │
└──────────────────────────────────────────────────────┘
```

### Traffic Flow

**Inbound (User → App):**
```
Internet → IGW → NLB (Public Subnets) → EC2 (Private Subnets)
```

**Outbound (App → Internet):**
```
EC2 (Private Subnets) → NAT Gateway (per AZ) → IGW → Internet
```

**High Availability:**
- ✅ Each AZ has its own NAT Gateway
- ✅ If one AZ fails, traffic routes to healthy AZ
- ✅ No single point of failure

---

## 🛠️ Tech Stack

<table>
<tr>
<td><b>IaC</b></td>
<td>Terraform 1.8+</td>
</tr>
<tr>
<td><b>Cloud Provider</b></td>
<td>AWS (VPC, EC2, NLB, NAT Gateway, IGW)</td>
</tr>
<tr>
<td><b>Compute</b></td>
<td>EC2 Auto Scaling Group (t3.micro)</td>
</tr>
<tr>
<td><b>Load Balancer</b></td>
<td>Network Load Balancer (Layer 4)</td>
</tr>
<tr>
<td><b>Runtime</b></td>
<td>Node.js 20.x</td>
</tr>
<tr>
<td><b>Framework</b></td>
<td>Express.js 4.18</td>
</tr>
<tr>
<td><b>Scripting</b></td>
<td>Bash (bootstrap.sh)</td>
</tr>
<tr>
<td><b>Networking</b></td>
<td>Multi-AZ VPC with public/private subnets</td>
</tr>
</table>

---

## 📁 Project Structure

```
simple-webapp-ec2-nlb-asg/
├── infra-iac/
│   ├── main.tf              # Main configuration
│   ├── provider.tf          # AWS provider
│   ├── variables.tf         # Input variables
│   ├── outputs.tf           # Output values
│   ├── networking.tf        # VPC, Subnets, IGW, NAT GW
│   ├── security.tf          # Security Groups
│   ├── compute.tf           # Launch Template, ASG
│   └── loadbalancer.tf      # NLB, Target Group, Listener
├── envs/
│   ├── dev.tfvars           # Development config
│   └── prod.tfvars          # Production config
├── userdata/
│   └── bootstrap.sh         # EC2 initialization script
├── scripts/
│   └── start.sh             # Deployment helper
├── images/
│   └── result.png           # Screenshot
└── README.md
```

---

## ⚙️ Setup Guide

### Prerequisites
- ✅ Terraform ≥ 1.8.0
- ✅ AWS CLI configured
- ✅ AWS Account with appropriate permissions
- ✅ EC2 Key Pair (optional, for SSH access)

### Step 1: Clone Repository
```bash
git clone https://github.com/engabelal/simple-webapp-ec2-nlb-asg.git
cd simple-webapp-ec2-nlb-asg
```

### Step 2: Configure Variables
Edit `envs/dev.tfvars`:
```hcl
project_name    = "simple-webapp"
environment     = "dev"
region          = "eu-north-1"
vpc_cidr        = "10.0.0.0/16"
public_subnets  = ["10.0.1.0/24", "10.0.2.0/24"]
private_subnets = ["10.0.3.0/24", "10.0.4.0/24"]
azs             = ["eu-north-1a", "eu-north-1b"]
ami_id          = "ami-04c08fd8aa14af291"  # Amazon Linux 2023
key_pair_name   = "your-key-pair"          # Optional
```

### Step 3: Initialize Terraform
```bash
cd infra-iac
terraform init
```

### Step 4: Plan Deployment
```bash
terraform plan -var-file="../envs/dev.tfvars"
```

### Step 5: Deploy Infrastructure
```bash
terraform apply -var-file="../envs/dev.tfvars"
```

### Step 6: Get NLB URL
```bash
NLB_DNS=$(terraform output -raw nlb_dns_name)
echo "Application URL: http://$NLB_DNS"
```

---

## 🚀 Deployment Scenarios

### Scenario 1: Development Environment
```bash
cd infra-iac
terraform init
terraform apply -var-file="../envs/dev.tfvars"
```
**Result:** 2 instances, t3.micro, minimal cost

---

### Scenario 2: Production Environment
```bash
cd infra-iac
terraform init
terraform apply -var-file="../envs/prod.tfvars"
```
**Result:** 4 instances, t3.small, high availability

---

### Scenario 3: Test Load Balancing
```bash
# Get NLB DNS
NLB_DNS=$(terraform output -raw nlb_dns_name)

# Multiple requests show different instances
for i in {1..10}; do
  curl http://$NLB_DNS | grep "Instance ID"
done
```

---

### Scenario 4: Test Auto Scaling
```bash
# Terminate an instance
aws ec2 terminate-instances --instance-ids <instance-id>

# Watch ASG replace it automatically
watch -n 5 'aws autoscaling describe-auto-scaling-groups \
  --auto-scaling-group-names simple-webapp-dev-asg \
  --query "AutoScalingGroups[0].Instances[*].[InstanceId,HealthStatus]" \
  --output table'
```

---

### Scenario 5: Destroy Infrastructure
```bash
cd infra-iac
terraform destroy -var-file="../envs/dev.tfvars"
```

---

## 💰 Cost Breakdown

### Development Environment (Monthly)

| Component | Quantity | Unit Cost | Total |
|-----------|----------|-----------|-------|
| **EC2 (t3.micro)** | 2 | $7.50 | $15.00 |
| **Network Load Balancer** | 1 | $16.20 | $16.20 |
| **NAT Gateway** | 2 | $32.40 | $64.80 |
| **Data Transfer** | Variable | - | ~$5.00 |
| **EBS Storage** | 16 GB | $0.08/GB | $1.28 |
| **Total** | - | - | **~$102/month** |

### Production Environment (Monthly)

| Component | Quantity | Unit Cost | Total |
|-----------|----------|-----------|-------|
| **EC2 (t3.small)** | 4 | $15.00 | $60.00 |
| **Network Load Balancer** | 1 | $16.20 | $16.20 |
| **NAT Gateway** | 2 | $32.40 | $64.80 |
| **Data Transfer** | Variable | - | ~$10.00 |
| **EBS Storage** | 32 GB | $0.08/GB | $2.56 |
| **Total** | - | - | **~$153/month** |

**💡 Cost Optimization Tips:**
- Use Spot Instances for dev (save 70%)
- Schedule scaling (scale down at night)
- Use single NAT Gateway for dev (save $32)
- Enable S3 VPC Endpoint (free data transfer)

---

## 🔧 Troubleshooting

| Issue | Solution |
|-------|----------|
| **NLB not accessible** | • Check security group allows port 3000<br>• Verify target health in AWS Console<br>• Wait 2-3 minutes for NLB to be active |
| **Instances unhealthy** | • Check user data script logs: `/var/log/user-data.log`<br>• Verify Node.js app is running: `systemctl status nodejs-app`<br>• Check security group allows NLB traffic on port 3000 |
| **Terraform state locked** | `terraform force-unlock <LOCK_ID>` |
| **AMI not found** | Update `ami_id` in tfvars for your region |
| **NAT Gateway timeout** | • Check route tables<br>• Verify NAT GW has Elastic IP<br>• Check NACL rules |
| **Auto Scaling not working** | • Check ASG health check settings<br>• Verify launch template is valid<br>• Check CloudWatch logs |

---

## 🧪 Testing

### Test Load Balancing
```bash
NLB_DNS=$(terraform output -raw nlb_dns_name)

# Should show different instance IDs
for i in {1..20}; do
  curl -s http://$NLB_DNS | grep "Instance ID"
  sleep 1
done
```

### Test High Availability
```bash
# Terminate instance in AZ-1a
aws ec2 terminate-instances --instance-ids <instance-id-az1a>

# Traffic should continue via AZ-1b
curl http://$NLB_DNS
```

### Test Auto Scaling
```bash
# Watch ASG maintain desired count
watch -n 5 'aws autoscaling describe-auto-scaling-groups \
  --auto-scaling-group-names simple-webapp-dev-asg \
  --query "AutoScalingGroups[0].[DesiredCapacity,MinSize,MaxSize]" \
  --output table'
```

---

## 📚 Advanced Topics

<details>
<summary><b>🔍 Why NAT Gateway per AZ?</b></summary>

### High Availability Benefits

**Single NAT Gateway (Not Recommended):**
```
AZ-1a: EC2 → NAT GW (AZ-1a) → Internet ✅
AZ-1b: EC2 → NAT GW (AZ-1a) → Internet ❌ (Cross-AZ traffic)
```
- ❌ Single point of failure
- ❌ Cross-AZ data transfer costs
- ❌ If AZ-1a fails, AZ-1b loses internet

**NAT Gateway per AZ (Recommended):**
```
AZ-1a: EC2 → NAT GW (AZ-1a) → Internet ✅
AZ-1b: EC2 → NAT GW (AZ-1b) → Internet ✅
```
- ✅ No single point of failure
- ✅ No cross-AZ data transfer
- ✅ Full redundancy

**Cost vs Reliability:**
- Extra cost: ~$32/month per NAT GW
- Benefit: 99.99% availability
- Production: Always use NAT GW per AZ
- Development: Can use single NAT GW to save cost

</details>

<details>
<summary><b>🏗️ Infrastructure Components Explained</b></summary>

### VPC & Networking
- **VPC**: Isolated network (10.0.0.0/16)
- **Public Subnets**: Host NLB and NAT Gateways
- **Private Subnets**: Host EC2 instances (no direct internet)
- **Internet Gateway**: Public internet access
- **NAT Gateways**: Outbound internet for private instances
- **Route Tables**: Traffic routing rules

### Compute
- **Launch Template**: EC2 configuration blueprint
- **Auto Scaling Group**: Maintains instance count
- **User Data**: Bootstrap script (installs Apache)

### Load Balancing
- **Network Load Balancer**: Layer 4 (TCP) load balancing
- **Target Group**: Health checks and routing
- **Listener**: Port 80 traffic forwarding

### Security
- **Security Group**: Firewall rules
  - Inbound: Port 3000 from anywhere
  - Outbound: All traffic allowed

</details>

<details>
<summary><b>🔒 Security Best Practices</b></summary>

### Implemented
- ✅ EC2 instances in private subnets
- ✅ No public IPs on instances
- ✅ Security groups with minimal permissions (port 3000 only)
- ✅ NAT Gateway for outbound only
- ✅ Multi-AZ for high availability
- ✅ Non-privileged port (3000) for Node.js
- ✅ Systemd service for auto-restart

### Recommended Additions
- 🔄 Enable VPC Flow Logs
- 🔄 Add WAF to NLB
- 🔄 Implement HTTPS (ALB + ACM)
- 🔄 Use AWS Secrets Manager
- 🔄 Enable CloudTrail
- 🔄 Add CloudWatch Alarms

</details>

<details>
<summary><b>📊 Monitoring & Alerts</b></summary>

### CloudWatch Metrics to Monitor
- EC2 CPU Utilization
- Network In/Out
- Target Health Count
- NLB Active Connections
- NAT Gateway Bytes Processed

### Recommended Alarms
```bash
# High CPU alarm
aws cloudwatch put-metric-alarm \
  --alarm-name high-cpu \
  --metric-name CPUUtilization \
  --threshold 80 \
  --comparison-operator GreaterThanThreshold

# Unhealthy targets
aws cloudwatch put-metric-alarm \
  --alarm-name unhealthy-targets \
  --metric-name UnHealthyHostCount \
  --threshold 1 \
  --comparison-operator GreaterThanOrEqualToThreshold
```

</details>

---

## 🎓 Learning Outcomes

After completing this project, you'll understand:

✅ **Multi-AZ Architecture** - High availability design patterns  
✅ **Auto Scaling** - Automatic capacity management  
✅ **Load Balancing** - Traffic distribution strategies  
✅ **VPC Networking** - Public/private subnet design  
✅ **NAT Gateway** - Outbound internet for private resources  
✅ **Security Groups** - Network-level security  
✅ **Infrastructure as Code** - Terraform best practices  
✅ **Cost Optimization** - AWS pricing and optimization  

---

## 🧹 Cleanup

### Remove All Resources
```bash
cd infra-iac
terraform destroy -var-file="../envs/dev.tfvars"
```

### Verify Cleanup
```bash
# Check no resources remain
aws ec2 describe-instances --filters "Name=tag:Project,Values=simple-webapp"
aws elbv2 describe-load-balancers --names simple-webapp-dev-nlb
aws ec2 describe-nat-gateways --filter "Name=tag:Project,Values=simple-webapp"
```

---

## 📝 License

MIT License - Free to use for learning and production!

---

## 👨💻 Author

**Ahmed Belal** - DevOps & Cloud Engineer

🔗 [GitHub](https://github.com/engabelal) • [LinkedIn](https://linkedin.com/in/engabelal) • [Email](mailto:eng.abelal@gmail.com)

---

## 🌟 Support

⭐ **Star this repo** if you found it helpful!

🐛 **Found a bug?** Open an issue  
💡 **Have suggestions?** Create a pull request  
📧 **Questions?** Reach out via email

---

**Built with ❤️ by Ahmed Belal | ABCloudOps**
