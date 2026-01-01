# VPC
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name        = "${var.name_prefix}-vpc"
    Environment = "dev"
    Owner       = var.name_prefix
  }
}

# Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name        = "${var.name_prefix}-igw"
    Environment = "dev"
    Owner       = var.name_prefix
  }
}

# Subnets
resource "aws_subnet" "public_subnet_01" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnet_01_cidr
  availability_zone       = "${var.aws_region}a"
  map_public_ip_on_launch = var.map_public_ip_on_launch

  tags = {
    Name = "${var.name_prefix}-public-subnet-01"
  }
}

resource "aws_subnet" "public_subnet_02" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnet_02_cidr
  availability_zone       = "${var.aws_region}b"
  map_public_ip_on_launch = var.map_public_ip_on_launch

  tags = {
    Name = "${var.name_prefix}-public-subnet-02"
  }
}

resource "aws_subnet" "private_subnet_01" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_subnet_01_cidr
  availability_zone = "${var.aws_region}a"

  tags = {
    Name = "${var.name_prefix}-private-subnet-01"
  }
}

resource "aws_subnet" "private_subnet_02" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_subnet_02_cidr
  availability_zone = "${var.aws_region}b"

  tags = {
    Name = "${var.name_prefix}-private-subnet-02"
  }
}

# NAT Gateway
resource "aws_eip" "nat1_eip" {
  tags = {
    Name        = "${var.name_prefix}-nat1-eip"
    Environment = "dev"
    Owner       = var.name_prefix
  }
}

resource "aws_eip" "nat2_eip" {
  tags = {
    Name        = "${var.name_prefix}-nat2-eip"
    Environment = "dev"
    Owner       = var.name_prefix
  }
}

resource "aws_nat_gateway" "natgw1a" {
  allocation_id = aws_eip.nat1_eip.id
  subnet_id     = aws_subnet.public_subnet_01.id

  tags = {
    Name        = "${var.name_prefix}-natgw1a"
    Environment = "dev"
    Owner       = var.name_prefix
  }

  depends_on = [aws_internet_gateway.igw]
}

resource "aws_nat_gateway" "natgw1b" {
  allocation_id = aws_eip.nat2_eip.id
  subnet_id     = aws_subnet.public_subnet_02.id

  tags = {
    Name        = "${var.name_prefix}-natgw1b"
    Environment = "dev"
    Owner       = var.name_prefix
  }

  depends_on = [aws_internet_gateway.igw]
}

# Route tables
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name        = "${var.name_prefix}-public-rt"
    Environment = "dev"
    Owner       = var.name_prefix
  }
}

resource "aws_route_table" "private_rt1" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.natgw1a.id
  }

  tags = {
    Name        = "${var.name_prefix}-private-rt1"
    Environment = "dev"
    Owner       = var.name_prefix
  }

  depends_on = [aws_nat_gateway.natgw1a]
}

resource "aws_route_table" "private_rt2" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.natgw1b.id
  }

  tags = {
    Name        = "${var.name_prefix}-private-rt2"
    Environment = "dev"
    Owner       = var.name_prefix
  }

  depends_on = [aws_nat_gateway.natgw1b]
}

# Route table associations
resource "aws_route_table_association" "public_subnet_01" {
  subnet_id      = aws_subnet.public_subnet_01.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_route_table_association" "public_subnet_02" {
  subnet_id      = aws_subnet.public_subnet_02.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_route_table_association" "private_subnet_01" {
  subnet_id      = aws_subnet.private_subnet_01.id
  route_table_id = aws_route_table.private_rt1.id
}

resource "aws_route_table_association" "private_subnet_02" {
  subnet_id      = aws_subnet.private_subnet_02.id
  route_table_id = aws_route_table.private_rt2.id
}