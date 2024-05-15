resource "aws_vpc" "kodehauz_vpc" {
  cidr_block           = var.vpc_cidr_block
  instance_tenancy     = "default"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = var.vpc_tag_name
  }
}

resource "aws_internet_gateway" "kodehauz_igw" {
  vpc_id = aws_vpc.kodehauz_vpc.id

  tags = {
    Name = "kodehauz_igw"
  }
  lifecycle {
    create_before_destroy = true
  }
}

data "aws_availability_zones" "available" {
  state = "available"
}

resource "aws_subnet" "public_subnet_1" {
  vpc_id                  = aws_vpc.kodehauz_vpc.id
  cidr_block              = var.public_subnet_1
  availability_zone       = data.aws_availability_zones.available.names[0]
  map_public_ip_on_launch = true
  tags = {
    Name = var.public_subnet_name_1
  }
}

resource "aws_subnet" "public_subnet_2" {
  vpc_id                  = aws_vpc.kodehauz_vpc.id
  cidr_block              = var.public_subnet_2
  availability_zone       = data.aws_availability_zones.available.names[1]
  map_public_ip_on_launch = true
  tags = {
    Name = var.public_subnet_name_2
  }
}

resource "aws_subnet" "private_subnet_1" {
  vpc_id                  = aws_vpc.kodehauz_vpc.id
  cidr_block              = var.private_subnet_1
  availability_zone       = data.aws_availability_zones.available.names[0]
  map_public_ip_on_launch = false
  tags = {
    Name = var.private_subnet_name_1
  }
}

resource "aws_subnet" "private_subnet_2" {
  vpc_id                  = aws_vpc.kodehauz_vpc.id
  cidr_block              = var.public_subnet_2
  availability_zone       = data.aws_availability_zones.available.names[1]
  map_public_ip_on_launch = false
  tags = {
    Name = var.private_subnet_name_2
  }
}

resource "aws_eip" "kodehauz_eip" {
  vpc = true
}

resource "aws_nat_gateway" "kodehauz_nat" {
  allocation_id = aws_eip.kodehauz_eip.id
  subnet_id     = aws_subnet.public_subnet_1.id
}

resource "aws_route_table" "public-rt" {
  vpc_id = aws_vpc.kodehauz_vpc.id

  tags = {
    Name = "kodehauz-pub-rt"
  }
}

resource "aws_route_table" "private-rt" {
  vpc_id = aws_vpc.kodehauz_vpc.id

  tags = {
    Name = "kodehauz-priv-rt"
  }
}

### Public Route Configuration
resource "aws_route" "public_route" {
  route_table_id         = aws_route_table.public-rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.kodehauz_igw.id
}

resource "aws_route_table_association" "public_rt_assoc_1" {
  subnet_id      = aws_subnet.public_subnet_1.id
  route_table_id = aws_route_table.public-rt.id
}

resource "aws_route_table_association" "public_rt_assoc_2" {
  subnet_id      = aws_subnet.public_subnet_2.id
  route_table_id = aws_route_table.public-rt.id
}

resource "aws_route" "private_route" {
  route_table_id         = aws_route_table.private-rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_nat_gateway.kodehauz_nat.id
}

resource "aws_route_table_association" "priv_rt_assoc_1" {
  subnet_id      = aws_subnet.private_subnet_1.id
  route_table_id = aws_route_table.private-rt.id
}

resource "aws_route_table_association" "priv_rt_assoc_2" {
  subnet_id      = aws_subnet.private_subnet_2.id
  route_table_id = aws_route_table.private-rt.id
}



