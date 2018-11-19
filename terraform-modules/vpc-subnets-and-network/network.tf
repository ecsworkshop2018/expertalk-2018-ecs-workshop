resource "aws_internet_gateway" "internet_gateway" {
  vpc_id = "${aws_vpc.vpc.id}"

  tags = {
    Name        = "${var.name}-internet-gateway"
    Environment = "${var.environment}"
  }
}

resource "aws_route_table" "public_route_table" {
  vpc_id = "${aws_vpc.vpc.id}"

  tags {
    Name        = "${var.name}-public-route-table"
    Environment = "${var.environment}"
  }
}

resource "aws_route" "public_route" {
  route_table_id         = "${aws_route_table.public_route_table.id}"
  destination_cidr_block = "${var.destination_cidr_block}"
  gateway_id             = "${aws_internet_gateway.internet_gateway.id}"
}

resource "aws_eip" "eip" {
  depends_on = ["aws_internet_gateway.internet_gateway"]
  vpc        = true
  count      = "${local.private_subnets_required ? 1 : 0}"

  tags = {
    Name        = "${var.name}-nat-eip"
    Environment = "${var.environment}"
  }
}

resource "aws_nat_gateway" "nat" {
  depends_on    = ["aws_internet_gateway.internet_gateway"]
  allocation_id = "${aws_eip.eip.id}"
  subnet_id     = "${element(aws_subnet.public_subnet.*.id, 0)}"
  count         = "${local.private_subnets_required ? 1 : 0}"

  tags = {
    Name        = "${var.name}-nat"
    Environment = "${var.environment}"
  }
}

resource "aws_route_table" "private_route_table" {
  vpc_id = "${aws_vpc.vpc.id}"
  count  = "${local.private_subnets_required ? 1 : 0}"

  tags {
    Name        = "${var.name}-private-route-table"
    Environment = "${var.environment}"
  }
}

resource "aws_route" "private_route" {
  route_table_id         = "${aws_route_table.private_route_table.id}"
  destination_cidr_block = "${var.destination_cidr_block}"
  nat_gateway_id         = "${aws_nat_gateway.nat.id}"
  count                  = "${local.private_subnets_required ? 1 : 0}"
}
