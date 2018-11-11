resource "aws_internet_gateway" "internet_gateway" {
  vpc_id = "${var.vpc_id}"

  tags = {
    Name        = "${var.name}-internet-gateway"
    Environment = "${var.environment}"
  }
}

resource "aws_eip" "eip" {
  depends_on = ["aws_internet_gateway.internet_gateway"]
  vpc        = true

  tags = {
    Name        = "${var.name}"
    Environment = "${var.environment}"
  }
}

resource "aws_nat_gateway" "nat" {
  depends_on    = ["aws_internet_gateway.internet_gateway"]
  allocation_id = "${aws_eip.eip.id}"
  subnet_id     = "${var.public_subnet_id}"

  tags = {
    Name        = "${var.name}"
    Environment = "${var.environment}"
  }
}

resource "aws_route_table" "private_route_table" {
  vpc_id = "${var.vpc_id}"

  tags {
    Name        = "${var.name}-private-route-table"
    Environment = "${var.environment}"
  }
}

resource "aws_route" "main_route" {
  route_table_id         = "${var.main_route_table_id}"
  destination_cidr_block = "${var.destination_cidr_block}"
  gateway_id             = "${aws_internet_gateway.internet_gateway.id}"
}

resource "aws_route" "private_route" {
  route_table_id         = "${aws_route_table.private_route_table.id}"
  destination_cidr_block = "${var.destination_cidr_block}"
  nat_gateway_id         = "${aws_nat_gateway.nat.id}"
}
