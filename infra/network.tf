resource "aws_vpc" "this" {
  cidr_block           = local.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags = {
    Name = "${local.prefix}-vpc"
  }
}

resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.this.id
  count                   = length(local.vpc_subnets_cidr_public)
  cidr_block              = element(local.vpc_subnets_cidr_public, count.index)
  availability_zone       = element(local.vpc_availability_zones, count.index)
  map_public_ip_on_launch = true
  tags = {
    Name = "${local.prefix}-public-${element(local.vpc_availability_zones, count.index)}"
  }
}

resource "aws_subnet" "private" {
  vpc_id                  = aws_vpc.this.id
  count                   = length(local.vpc_subnets_cidr_private)
  cidr_block              = element(local.vpc_subnets_cidr_private, count.index)
  availability_zone       = element(local.vpc_availability_zones, count.index)
  map_public_ip_on_launch = false
  tags = {
    Name = "${local.prefix}-private-${element(local.vpc_availability_zones, count.index)}"
  }
}

resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id
  tags = {
    Name = "${local.prefix}-igtw"
  }
}

resource "aws_eip" "this" {
  depends_on = [aws_internet_gateway.this]
  vpc        = true
}

resource "aws_nat_gateway" "this" {
  depends_on    = [aws_internet_gateway.this]
  allocation_id = aws_eip.this.id
  subnet_id     = element(aws_subnet.public.*.id, 0)
  tags = {
    Name = "${local.prefix}-nat-gtw"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id
  tags = {
    Name = "${local.prefix}-public-route-table"
  }
}

resource "aws_route_table_association" "public" {
  count          = length(local.vpc_subnets_cidr_public)
  subnet_id      = element(aws_subnet.public.*.id, count.index)
  route_table_id = aws_route_table.public.id
}

resource "aws_route" "public_internet_gateway" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.this.id
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.this.id
  tags = {
    Name = "${local.prefix}-private-route-table"
  }
}

resource "aws_route" "private_nat_gateway" {
  route_table_id         = aws_route_table.private.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.this.id
}

resource "aws_route_table_association" "private" {
  count          = length(local.vpc_subnets_cidr_private)
  subnet_id      = element(aws_subnet.private.*.id, count.index)
  route_table_id = aws_route_table.private.id
}
