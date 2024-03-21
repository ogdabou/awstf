# From https://spacelift.io/blog/terraform-ecs

## What I'm doing below is very vague

resource "aws_vpc" "superset" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  tags = {
    name = "main"
  }
}

resource "aws_subnet" "subnet" {
  vpc_id                  = aws_vpc.superset.id
  cidr_block              = cidrsubnet(aws_vpc.superset.cidr_block, 8, 1)
  map_public_ip_on_launch = true
  availability_zone       = "eu-west-1a"
}

resource "aws_subnet" "subnet2" {
  vpc_id                  = aws_vpc.superset.id
  cidr_block              = cidrsubnet(aws_vpc.superset.cidr_block, 8, 2)
  map_public_ip_on_launch = true
  availability_zone       = "eu-west-1b"
}



resource "aws_internet_gateway" "internet_gateway" {
  vpc_id = aws_vpc.superset.id
  tags = {
    Name = "internet_gateway"
  }
}


resource "aws_route_table" "route_table" {
  vpc_id = aws_vpc.superset.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.internet_gateway.id
  }
}

resource "aws_route_table_association" "subnet_route" {
  subnet_id      = aws_subnet.subnet.id
  route_table_id = aws_route_table.route_table.id
}

resource "aws_route_table_association" "subnet2_route" {
  subnet_id      = aws_subnet.subnet2.id
  route_table_id = aws_route_table.route_table.id
}

resource "aws_security_group" "security_group" {
  name   = "ecs-security-group"
  vpc_id = aws_vpc.superset.id

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    self        = "false"
    cidr_blocks = ["0.0.0.0/0"]
    description = "any"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}