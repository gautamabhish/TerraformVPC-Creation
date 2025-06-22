#!/bin/bash

# Disable UFW
sudo ufw disable || true

# Install Apache
sudo apt update -y
sudo apt install -y apache2

# Enable and start Apache
sudo systemctl enable apache2
sudo systemctl start apache2

# Get instance ID
INSTANCE_ID=$(curl -s http://169.254.169.254/latest/meta-data/instance-id)

# Write HTML
echo "<h1>Hello from Terraform on Ubuntu</h1><h2>Instance ID: $INSTANCE_ID</h2>" | sudo tee /var/www/html/index.html
