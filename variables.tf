variable "region" {
  default = "us-west-2"
}

variable "cidr_block" {
  default = "10.0.0.0/16"
}

data "aws_availability_zones" "myazs" {
  exclude_names = ["us-west-2d"]
}
variable "pub_cidr_block" {
  default = "10.0.1.0/24"
}

variable "priv_cidr_block" {
  type    = "list"
  default = ["10.0.2.0/24", "10.0.3.0/24", "10.0.4.0/24"]
}

variable "pub_cidr_block_lb" {
  type    = "list"
  default = ["10.0.20.0/24", "10.0.30.0/24", "10.0.40.0/24"]
}

variable "image_id" {
  default = "ami-02659f5ed9a07e3b2"
}

variable "instance_type" {
  default = "m5a.xlarge"
}
