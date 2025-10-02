#!/bin/bash
#cloud-config
set -e

# Update system and install Apache (example - adjust for your AMI)
dnf update -y
dnf install -y httpd
systemctl enable httpd
systemctl start httpd
echo "Welcome to My first AWS Template" > /var/www/html/index.html