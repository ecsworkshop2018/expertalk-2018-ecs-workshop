data aws_availability_zones all {}

resource "aws_subnet" "public_subnet" {
  vpc_id                  = "${aws_vpc.vpc.id}"
  cidr_block              = "${element(var.public_subnet_cidrs, count.index)}"
  map_public_ip_on_launch = true
  availability_zone       = "${element(data.aws_availability_zones.all.names, (count.index % 3))}"
  count                   = "${length(var.public_subnet_cidrs)}"

  tags = {
    Name        = "${var.name}-public-subnet-${count.index}"
    Environment = "${var.environment}"
    Type        = "public"
  }
}

resource "aws_route_table_association" "public_subnet_route_table_association" {
  subnet_id      = "${element(aws_subnet.public_subnet.*.id, count.index)}"
  route_table_id = "${aws_route_table.public_route_table.id}"
  count          = "${length(var.public_subnet_cidrs)}"
}

resource "aws_subnet" "private_subnet" {
  vpc_id                  = "${aws_vpc.vpc.id}"
  cidr_block              = "${element(var.private_subnet_cidrs, count.index)}"
  map_public_ip_on_launch = false
  availability_zone       = "${element(data.aws_availability_zones.all.names, (count.index % 3))}"
  count                   = "${length(var.private_subnet_cidrs)}"

  tags = {
    Name        = "${var.name}-private-subnet-${count.index}"
    Environment = "${var.environment}"
    Type        = "private"
  }
}

resource "aws_route_table_association" "private_subnet_route_table_association" {
  subnet_id      = "${element(aws_subnet.private_subnet.*.id, count.index)}"
  route_table_id = "${aws_route_table.private_route_table.id}"
  count          = "${length(var.private_subnet_cidrs)}"
}
