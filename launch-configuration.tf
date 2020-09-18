# Create Launch Configuration
resource "aws_launch_configuration" "my_launch_conf" {
  name_prefix     = "terraform-lc-example"
  image_id        = "${var.image_id}"
  instance_type   = "${var.instance_type}"
  security_groups = ["${aws_security_group.my_instance_sg.id}"]
  
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

#   provisioner "file" {
#     source      = "testscript.sh"
#     destination = "/tmp/testscript.sh"
#   }

#   provisioner "remote-exec" {
#     inline = [
#       "chmod +x /tmp/testscript.sh",
#       "/tmp/testscript.sh",
#     ]
#   }
# }
user_data       = "${file("newscript.sh")}"
lifecycle {
    create_before_destroy = true
  }
}

