resource "aws_route_table" "external_route_table" {
  vpc_id = "${aws_vpc.new_vpc.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.my_ig.id}"
  }


  tags = {
    Name = "External Route Table"
  }
}


resource "aws_route_table_association" "myextroutetableassoc" {
  subnet_id      = "${aws_subnet.my_pub_subnet.id}"
  route_table_id = "${aws_route_table.external_route_table.id}"
}

resource "aws_route_table_association" "myextroutetableassoc_lb" {

  #count          = "${length(aws_subnet.my_pub_subnet_lb.*.id)}"
  #count           = 2
  count = "${length(data.aws_availability_zones.myazs.names)}"
  #subnet_id     = "${aws_subnet.my_pub_subnet_lb.*.id[count.index]}"
  subnet_id      = "${element(aws_subnet.my_pub_subnet_lb.*.id, count.index)}" 
  route_table_id = "${aws_route_table.external_route_table.id}"
}


resource "aws_route_table" "internal_route_table" {
  vpc_id = "${aws_vpc.new_vpc.id}"

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = "${aws_nat_gateway.my_nat_gateway.id}"
  }

  tags = {
    Name = "Route Table to NAT"
  }
}

resource "aws_route_table_association" "myinternalroutetableassoc" {
  #count          = "${length(aws_subnet.my_priv_subnet.*.id)}"
  #count          = 2
  count = "${length(data.aws_availability_zones.myazs.names)}" 
  
  #subnet_id      = "${aws_subnet.my_priv_subnet.*.id[count.index]}"
  subnet_id      = "${element(aws_subnet.my_priv_subnet.*.id, count.index)}"
  route_table_id = "${aws_route_table.internal_route_table.id}"
}

