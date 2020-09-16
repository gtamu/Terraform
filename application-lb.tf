# Create Application Load Balancersd

resource "aws_lb" "myALB" {
  name               = "test-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = ["${aws_security_group.my_lb_sg.id}"]
  subnets            = ["${aws_subnet.my_pub_subnet_lb.*.id}"]

}

# Output the DNS Name of the LB
output "LB-DNS-name" {
  value = "${aws_lb.myALB.dns_name}"
}

# Create Listner
resource "aws_lb_listener" "mylblistner" {
  load_balancer_arn = "${aws_lb.myALB.arn}"
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "forward"

    target_group_arn = "${aws_lb_target_group.mylbtarget.arn}"
  }
}

# Create Target Group
resource "aws_lb_target_group" "mylbtarget" {
  name     = "test-lb-target-group"
  port     = 80
  protocol = "HTTP"
  vpc_id   = "${aws_vpc.new_vpc.id}"

  health_check {
    interval = 30
    path     = "/index.html"
    protocol = "HTTP"
    port     = 80
    matcher  = 200
  }

}
