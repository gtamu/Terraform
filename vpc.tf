resource "aws_vpc" "new_vpc" {
  cidr_block = "${var.cidr_block}"

  tags = {
    Name = "my_new_vpc"
  }
}

resource "aws_subnet" "my_pub_subnet" {
  vpc_id                  = "${aws_vpc.new_vpc.id}"
  cidr_block              = "${var.pub_cidr_block}"
  availability_zone       = "${element(data.aws_availability_zones.myazs.names, 0)}"
  map_public_ip_on_launch = true

  tags = {
    Name = "Public-Subnet"
  }

}

resource "aws_subnet" "my_priv_subnet" {
  count             = "${length(var.priv_cidr_block)}"
  vpc_id            = "${aws_vpc.new_vpc.id}"
  cidr_block        = "${element(var.priv_cidr_block, count.index)}"
  availability_zone = "${element(data.aws_availability_zones.myazs.names, count.index + 1)}"

  tags = {
    Name = "Private-Subnet-${count.index + 1}"
  }

}

resource "aws_subnet" "my_pub_subnet_lb" {
  count             = "${length(var.pub_cidr_block_lb)}"
  vpc_id            = "${aws_vpc.new_vpc.id}"
  cidr_block        = "${element(var.pub_cidr_block_lb, count.index)}"
  availability_zone = "${element(data.aws_availability_zones.myazs.names, count.index + 1)}"

  tags = {
    Name = "Public-Subnet-lb-${count.index + 1}"
  }

}


