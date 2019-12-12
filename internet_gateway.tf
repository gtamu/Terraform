resource "aws_internet_gateway" "my_ig" {
  vpc_id = "${aws_vpc.new_vpc.id}"

  tags = {
    Name = "My Internet Gateway"
  }
}
