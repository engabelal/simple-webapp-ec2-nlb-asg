#!/bin/bash
set -e

# Logging
exec > >(tee /var/log/user-data.log)
exec 2>&1

echo "Starting bootstrap at $(date)"

# Update system
yum update -y

# Install Node.js 20.x
curl -fsSL https://rpm.nodesource.com/setup_20.x | bash -
yum install -y nodejs

# Verify installation
node --version
npm --version

# Get instance metadata
INSTANCE_ID=$(curl -s http://169.254.169.254/latest/meta-data/instance-id)
AVAIL_ZONE=$(curl -s http://169.254.169.254/latest/meta-data/placement/availability-zone)
REGION=${AVAIL_ZONE::-1}

# Create app directory
mkdir -p /home/ec2-user/app
cd /home/ec2-user/app

# Create package.json
cat << 'EOF' > package.json
{
  "name": "abcloudops-demo",
  "version": "1.0.0",
  "description": "ABCloudOps AWS Infrastructure Demo",
  "main": "server.js",
  "scripts": {
    "start": "node server.js"
  },
  "author": "Ahmed Belal - ABCloudOps",
  "license": "MIT",
  "dependencies": {
    "express": "^4.18.2"
  }
}
EOF

# Create Node.js server
cat << EOF > server.js
const express = require('express');
const app = express();
const PORT = 3000;

// Instance metadata
const INSTANCE_ID = '${INSTANCE_ID}';
const AVAIL_ZONE = '${AVAIL_ZONE}';
const REGION = '${REGION}';

app.get('/', (req, res) => {
  res.send(\`
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1.0" />
  <title>ABCloudOps AWS Terraform Demo</title>
  <style>
    body {
      font-family: 'Segoe UI', sans-serif;
      background: linear-gradient(135deg, #1e293b, #0f172a);
      color: #e2e8f0;
      text-align: center;
      margin: 0;
      padding: 60px 20px;
    }
    h1 {
      font-size: 2.4rem;
      color: #38bdf8;
      margin-bottom: 0.2rem;
    }
    h2 {
      font-size: 1.3rem;
      color: #a5f3fc;
      font-weight: 400;
      margin-bottom: 2rem;
    }
    ul {
      list-style: none;
      padding: 0;
      text-align: left;
      display: inline-block;
      margin: 0 auto;
      font-size: 1rem;
      color: #f1f5f9;
    }
    li {
      margin: 10px 0;
      padding: 8px 14px;
      background: rgba(255, 255, 255, 0.05);
      border-radius: 8px;
      border: 1px solid rgba(255,255,255,0.08);
    }
    .card {
      background: rgba(255,255,255,0.05);
      border: 1px solid rgba(255,255,255,0.1);
      padding: 40px;
      margin: 40px auto;
      border-radius: 12px;
      max-width: 700px;
      box-shadow: 0 0 20px rgba(0,0,0,0.3);
    }
    .badge {
      display: inline-block;
      background: rgba(34, 197, 94, 0.2);
      color: #4ade80;
      padding: 4px 12px;
      border-radius: 12px;
      font-size: 0.85rem;
      margin-left: 8px;
    }
    footer {
      margin-top: 60px;
      font-size: 0.9rem;
      color: #94a3b8;
    }
  </style>
</head>
<body>
  <div class="card">
    <h1>🚀 ABCloudOps AWS Demo <span class="badge">Node.js</span></h1>
    <h2>Infrastructure built automatically using Terraform</h2>

    <p style="background: rgba(56,189,248,0.1); padding: 15px; border-radius: 8px; border-left: 4px solid #38bdf8;">
      <b>Instance ID:</b> \${INSTANCE_ID}<br>
      <b>Availability Zone:</b> \${AVAIL_ZONE}<br>
      <b>Region:</b> \${REGION}<br>
      <b>Runtime:</b> Node.js \${process.version}
    </p>

    <p>
      This demo environment showcases a full AWS Infrastructure as Code (IaC) setup
      deployed with <b>Terraform</b>. It represents a production-like architecture
      designed for scalability, automation, and learning.
    </p>

    <ul>
      <li>☁️ <b>VPC</b> — defines the network boundary for all resources.</li>
      <li>🌐 <b>Public & Private Subnets</b> — separate layers for web and app tiers.</li>
      <li>🚪 <b>Internet Gateway</b> — enables public internet access.</li>
      <li>🔄 <b>NAT Gateway per AZ</b> — allows private instances outbound access securely.</li>
      <li>🛡️ <b>Security Groups</b> — manage inbound/outbound rules.</li>
      <li>🖥️ <b>Launch Template</b> — defines EC2 configuration and bootstrap.</li>
      <li>⚙️ <b>Auto Scaling Group</b> — maintains instance count automatically.</li>
      <li>🔁 <b>Network Load Balancer</b> — distributes incoming traffic.</li>
      <li>🧰 <b>User Data</b> — installs Node.js and serves this page.</li>
      <li>📦 <b>Terraform Variables</b> — parameterize environment configurations.</li>
    </ul>

    <p style="margin-top:20px;">
      Together, these components demonstrate how a complete AWS environment can be
      provisioned automatically and reproducibly using <b>Terraform</b>.
    </p>
  </div>

  <footer>
    © 2025 ABCloudOps | Infrastructure as Code Demo | Powered by Node.js
  </footer>
</body>
</html>
  \`);
});

app.get('/health', (req, res) => {
  res.json({ 
    status: 'healthy',
    instance: INSTANCE_ID,
    zone: AVAIL_ZONE,
    region: REGION,
    uptime: process.uptime()
  });
});

app.listen(PORT, '0.0.0.0', () => {
  console.log(\`Server running on port \${PORT}\`);
  console.log(\`Instance: \${INSTANCE_ID}\`);
  console.log(\`Zone: \${AVAIL_ZONE}\`);
});
EOF

# Install dependencies
npm install

# Set ownership
chown -R ec2-user:ec2-user /home/ec2-user/app

# Create systemd service
cat << 'EOF' > /etc/systemd/system/nodejs-app.service
[Unit]
Description=ABCloudOps Node.js Demo App
After=network.target

[Service]
Type=simple
User=ec2-user
WorkingDirectory=/home/ec2-user/app
ExecStart=/usr/bin/node server.js
Restart=always
RestartSec=10
StandardOutput=journal
StandardError=journal
SyslogIdentifier=nodejs-app

[Install]
WantedBy=multi-user.target
EOF

# Enable and start service
systemctl daemon-reload
systemctl enable nodejs-app
systemctl start nodejs-app

# Wait for app to start
sleep 5

# Check if app is running
if systemctl is-active --quiet nodejs-app; then
  echo "✅ Node.js app started successfully"
  systemctl status nodejs-app
else
  echo "❌ Failed to start Node.js app"
  journalctl -u nodejs-app -n 50
  exit 1
fi

echo "Bootstrap completed successfully at $(date)"
