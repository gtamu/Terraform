resource "aws_eip" "my_nat_eip" {
  vpc              = true
  public_ipv4_pool = "amazon"

}
