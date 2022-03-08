resource "aws_vpc" "chmx-hw-main-vpc-001" {
  cidr_block       = "172.16.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name = "chmx-hw-main-vpc-001"
  }
}

resource "aws_internet_gateway" "chmx-hw-main-IGW" {
  vpc_id = aws_vpc.chmx-hw-main-vpc-001.id
}

resource "aws_subnet" "chmx-hw-main-snet-pub" {
  count             = length(var.public_subnet)
  vpc_id            = aws_vpc.chmx-hw-main-vpc-001.id
  cidr_block        = var.public_subnet[count.index]
  availability_zone = data.aws_availability_zones.available.names[count.index]
}

resource "aws_subnet" "chmx-hw-main-snet-priv" {
  count             = length(var.private_subnet)
  vpc_id            = aws_vpc.chmx-hw-main-vpc-001.id
  cidr_block        = var.private_subnet[count.index]
  availability_zone = data.aws_availability_zones.available.names[count.index]
}

resource "aws_route_table" "PubToExt" {
  vpc_id = aws_vpc.chmx-hw-main-vpc-001.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.chmx-hw-main-IGW.id
  }
}
resource "aws_route_table" "PrivToNat" {
  count  = length(var.private_subnet)
  vpc_id = aws_vpc.chmx-hw-main-vpc-001.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = element(aws_nat_gateway.chmx-hw-main-nat.*.id, count.index)
  }
}

resource "aws_route_table_association" "PubRouteassociation" {
  count          = length(var.public_subnet)
  subnet_id      = element(aws_subnet.chmx-hw-main-snet-pub.*.id, count.index)
  route_table_id = aws_route_table.PubToExt.id
}

resource "aws_route_table_association" "PrivRouteassociation" {
  count          = length(var.private_subnet)
  subnet_id      = element(aws_subnet.chmx-hw-main-snet-priv.*.id, count.index)
  route_table_id = element(aws_route_table.PrivToNat.*.id, count.index)

}

resource "aws_security_group" "default" {
  vpc_id = "aws_vpc.chmx-hw-main-vpc-001.id"

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_eip" "nat" {
  count = length(var.public_subnet)
  vpc   = true
}

resource "aws_nat_gateway" "chmx-hw-main-nat" {
  count         = length(var.public_subnet)
  allocation_id = element(aws_eip.nat.*.id, count.index)
  subnet_id     = element(aws_subnet.chmx-hw-main-snet-pub.*.id, count.index)
}

resource "aws_vpc_endpoint" "chmx-hw-main-vpc-s3" {
  vpc_id            = aws_vpc.chmx-hw-main-vpc-001.id
  vpc_endpoint_type = "Gateway"
  service_name      = "com.amazonaws.eu-west-2.s3"
  route_table_ids   = concat(aws_route_table.PubToExt.*.id, aws_route_table.PrivToNat.*.id)
}
