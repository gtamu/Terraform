# Terraform code to build VPC with Application Load Balancer in Public subnet and its target Web servers in Private Subnet.


1. Bastion host is created in a public subnet in us-east-2a AZ.
2. Two webservers are created in a private subnet in us-east-2b and us-east-2c AZs.
3. Two webservers from above can get to outside world through NAT gateway created in public subnet in us-east-2a AZ.
4. Two public subnets are also created in us-east-2b and us-east-2c AZs.
5. Application Load Balancer is created in public subnets from step 4 and is tied to web servers from step 2 above.
6. Only Bastion host can SSH and ping two web servers created above.
7. Port 80 of two webservers is open to Bastion Host (for testing) and Application Load Balancer only.
