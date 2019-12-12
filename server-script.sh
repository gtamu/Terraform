#!/bin/bash
sudo yum update
sudo yum install -y httpd
sudo systemctl start httpd
sudo systemctl enable httpd
echo "<html><h1>Created by Terraform Script</h1><a href="https://github.com/gtamu/terraform">Github</a></html>" | sudo tee /var/www/html/index.html
