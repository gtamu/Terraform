

# Security Group for the Load-balancer to allow port 80 to the world
resource "aws_security_group" "my_lb_sg" {
  name   = "allow_http"
  vpc_id = "${aws_vpc.new_vpc.id}"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 80
    to_port     = 80
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "my_lb_sec_group"
  }

}


# Security Group Rule for the Bastion Host
resource "aws_security_group" "my_bastion_sg" {
  name   = "allow_ssh"
  vpc_id = "${aws_vpc.new_vpc.id}"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 22
    to_port     = 22
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 80
    to_port     = 80
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = -1
    to_port     = -1
    protocol    = "ICMP"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "my_bastion_sec_group"
  }

}

# Security Group Rules for the autoscaling group
resource "aws_security_group" "my_instance_sg" {
  name   = "allow_lb_sec_group"
  vpc_id = "${aws_vpc.new_vpc.id}"

  # Below egress gives outbound port 80 access to the world to download the package.
  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "TCP"
    security_groups = ["${aws_security_group.my_bastion_sg.id}", "${aws_security_group.my_lb_sg.id}"]
  }

  egress {
    from_port   = 80
    to_port     = 80
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Below egress gives outbound port 80 access to the world to download the package.
  ingress {
    from_port       = 443
    to_port         = 443
    protocol        = "TCP"
    security_groups = ["${aws_security_group.my_bastion_sg.id}", "${aws_security_group.my_lb_sg.id}"]
  }

  egress {
    from_port   = 443
    to_port     = 443
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow SSH only from the Security Group which bastion host is associated with

  ingress {
    from_port       = 22
    to_port         = 22
    protocol        = "TCP"
    security_groups = ["${aws_security_group.my_bastion_sg.id}"]

  }

  # ICMP  
  ingress {
    from_port       = -1
    to_port         = -1
    protocol        = "ICMP"
    security_groups = ["${aws_security_group.my_bastion_sg.id}"]
  }


  tags = {
    Name = "allow_lb_sec_group"
  }


}


