resource "aws_instance" "bastion" {
  ami             = "${var.image_id}"
  instance_type   = "${var.instance_type}"
  user_data       = "${file("server-script.sh")}"
  security_groups = ["${aws_security_group.my_bastion_sg.id}"]
  subnet_id       = "${aws_subnet.my_pub_subnet.id}"
  #associate_public_ip_address = true
  key_name = "keyp-usw2-cops"

  tags = {

    Name = "Gtest-Bastion-host"
  }

  depends_on = ["aws_internet_gateway.my_ig"]

}
