resource "aws_subnet" "subnet" {
  vpc_id                  = "${var.vpc_id}"
  cidr_block              = "${var.cidr}"
  map_public_ip_on_launch = "${var.is_public}"
  availability_zone       = "${var.az}"

  tags = {
    Name        = "${var.name}"
    Environment = "${var.environment}"
  }
}

resource "aws_route_table_association" "route_table_association" {
  subnet_id      = "${aws_subnet.subnet.id}"
  route_table_id = "${var.route_table_id}"
}
