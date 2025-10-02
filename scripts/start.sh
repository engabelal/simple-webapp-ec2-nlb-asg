#!/bin/bash
set -e

# Check if Apache is installed, if not install it
if ! command -v httpd &> /dev/null; then
  echo "Installing Apache (httpd)..."
  dnf install -y httpd
  systemctl enable httpd
fi

# Start / Restart Apache
echo "Starting Apache..."
systemctl restart httpd

# Add default index.html if not exists
if [ ! -f /var/www/html/index.html ]; then
  echo "Welcome to My First AWS Pipeline Deployment" > /var/www/html/index.html
fi