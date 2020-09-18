# Create Auto Scaling Group

resource "aws_autoscaling_group" "test_autoscale_group" {
  name = "terraform-asg"
  #count                = "${length(data.aws_availability_zones.myazs)}"
  launch_configuration = "${aws_launch_configuration.my_launch_conf.name}"
  min_size             = 2
  max_size             = 2
  desired_capacity     = 2
  target_group_arns    = ["${aws_lb_target_group.mylbtarget.arn}"]
  vpc_zone_identifier  = ["${aws_subnet.my_priv_subnet.*.id}"]
   
   tag {
    key                 = "Name"
    value               = "Gtest-OpsMgr"
    propagate_at_launch = true
  }

  lifecycle {
    create_before_destroy = true
  }
}