//connections.tf
provider "aws" {
  region = "ap-south-1"
}
//network.tf
resource "aws_vpc" "ankit-terra" {
  cidr_block = "172.17.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support = true
  tags = {
    Name = "ankit-terra"
  }
}
//subnets.tf
resource "aws_subnet" "subnet-terra" {
  cidr_block = "${cidrsubnet(aws_vpc.ankit-terra.cidr_block, 3, 1)}"
  vpc_id = "${aws_vpc.ankit-terra.id}"
  availability_zone = "ap-south-1a"
}
//security.tf
resource "aws_security_group" "sec-terra" {
name = "allow-all-sg"
vpc_id = "${aws_vpc.ankit-terra.id}"
ingress {
    cidr_blocks = [
      "0.0.0.0/0"
    ]
from_port = 3306
    to_port = 3306
    protocol = "tcp"
  }
ingress {
    cidr_blocks = [
      "0.0.0.0/0"
    ]
from_port = 22
    to_port = 22
    protocol = "tcp"
  }
  ingress {
    cidr_blocks = [
      "0.0.0.0/0"
    ]
from_port = 80
    to_port = 80
    protocol = "tcp"
  }
// Terraform removes the default rule
  egress {
   from_port = 0
   to_port = 0
   protocol = "-1"
   cidr_blocks = ["0.0.0.0/0"]
 }
}
//servers.tf
resource "aws_instance" "test-ec2-instance" {
#  ami = "${var.ami_id}"
  ami = "ami-0a74bfeb190bd404f"
  instance_type = "t2.micro"
  key_name = "ankitlinux2"
  security_groups = ["${aws_security_group.sec-terra.id}"]
tags = {
    Name = "${var.ami_name}"
  }
user_data = "${file("wp.sh")}"
subnet_id = "${aws_subnet.subnet-terra.id}"
}

resource "aws_eip" "ip-ankit-terra" {
  instance = "${aws_instance.test-ec2-instance.id}"
  vpc      = true
}
//gateways.tf
resource "aws_internet_gateway" "ankit-terra-gw" {
  vpc_id = "${aws_vpc.ankit-terra.id}"
tags = {
    Name = "ankit-terra-gw"
  }
}
//subnets.tf
resource "aws_route_table" "route-table-ankit-terra" {
  vpc_id = "${aws_vpc.ankit-terra.id}"
route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.ankit-terra-gw.id}"
  }
tags = {
    Name = "ankit-terra-route-table"
  }
}
resource "aws_route_table_association" "subnet-association" {
  subnet_id      = "${aws_subnet.subnet-terra.id}"
  route_table_id = "${aws_route_table.route-table-ankit-terra.id}"
}