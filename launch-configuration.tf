# Create Launch Configuration
resource "aws_launch_configuration" "my_launch_conf" {
  name_prefix     = "terraform-lc-example"
  image_id        = "${var.image_id}"
  instance_type   = "${var.instance_type}"
  security_groups = ["${aws_security_group.my_instance_sg.id}"]
  user_data       = "${file("testscript.sh")}"
  key_name        = "keyp-usw2-cops"

  ebs_block_device {
    device_name = "/dev/sdh"
    volume_type = "gp2"
    volume_size = "40"

  }

  ebs_block_device {
    device_name = "/dev/sdf"
    volume_type = "gp2"
    volume_size = "40"

  }

  lifecycle {
    create_before_destroy = true
  }
}

