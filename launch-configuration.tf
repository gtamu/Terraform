# Create Launch Configuration
resource "aws_launch_configuration" "my_launch_conf" {
  name_prefix     = "terraform-lc-example"
  image_id        = "${var.image_id}"
  instance_type   = "${var.instance_type}"
  security_groups = ["${aws_security_group.my_instance_sg.id}"]
  user_data       = "${file("server-script.sh")}"
  key_name        = "${aws_key_pair.sshkey.key_name}"


  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_key_pair" "sshkey" {
  key_name   = "deployer-key"
  public_key = "${file("my_id_rsa.pub")}"
}