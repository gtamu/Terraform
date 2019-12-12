

resource "aws_nat_gateway" "my_nat_gateway" {
  subnet_id     = "${aws_subnet.my_pub_subnet.id}"
  allocation_id = "${aws_eip.my_nat_eip.id}"

}
