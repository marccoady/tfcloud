# ---- netsec/main.tf


resource "random_integer" "random" {
  min = 1
  max = 100
}

resource "aws_vpc" "ttp_vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "ttp_vpc-${random_integer.random.id}"
  }
}

resource "aws_subnet" "ttp_pb_sn" {
  count                   = length(var.pb_cidrs)
  vpc_id                  = aws_vpc.ttp_vpc.id
  cidr_block              = var.pb_cidrs[count.index]
  map_public_ip_on_launch = true
  availability_zone       = ["us-east-1a", "us-east-1b", "us-east-1c"][count.index]

  tags = {
    Name = "ttp-pb_${count.index + 1}"
  }
}

resource "aws_route_table_association" "ttp_public_assoc" {
  count          = length(var.pb_cidrs)
  subnet_id      = aws_subnet.ttp_pb_sn.*.id[count.index]
  route_table_id = aws_route_table.ttp_pb_rt.id
}

resource "aws_subnet" "ttp_pt_sn" {
  count             = length(var.pt_cidrs)
  vpc_id            = aws_vpc.ttp_vpc.id
  cidr_block        = var.pt_cidrs[count.index]
  availability_zone = ["us-east-1a", "us-east-1b", "us-east-1c"][count.index]

  tags = {
    Name = "ttp_pt-${count.index + 1}"
  }
}

resource "aws_route_table_association" "ttp_pt_assoc" {
  count          = length(var.pt_cidrs)
  subnet_id      = aws_subnet.ttp_pt_sn.*.id[count.index]
  route_table_id = aws_route_table.ttp_pt_rt.id
}

resource "aws_internet_gateway" "ttp_ig" {
  vpc_id = aws_vpc.ttp_vpc.id

  tags = {
    Name = "ttp-igw"
  }
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_eip" "ttp_eip" {

}

resource "aws_nat_gateway" "ttp_natgateway" {
  allocation_id = aws_eip.ttp_eip.id
  subnet_id     = aws_subnet.ttp_pb_sn[1].id
}

resource "aws_route_table" "ttp_pb_rt" {
  vpc_id = aws_vpc.ttp_vpc.id

  tags = {
    Name = "ttp-pub-rt"
  }
}

resource "aws_route" "default_pb_route" {
  route_table_id         = aws_route_table.ttp_pb_rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.ttp_ig.id
}

resource "aws_route_table" "ttp_pt_rt" {
  vpc_id = aws_vpc.ttp_vpc.id

  tags = {
    Name = "ttp-private-rt"
  }
}

resource "aws_route" "default_pt_route" {
  route_table_id         = aws_route_table.ttp_pt_rt.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.ttp_natgateway.id
}

resource "aws_default_route_table" "ttp_pt_rt" {
  default_route_table_id = aws_vpc.ttp_vpc.default_route_table_id

  tags = {
    Name = "ttp-private-rt"
  }
}
resource "aws_security_group" "ttp_pb_sg" {
  name        = "ttp_bastion_sg"
  description = "SSH inbound traffic"
  vpc_id      = aws_vpc.ttp_vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.ext_ip]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "ttp_pt_sg" {
  name        = "ttp_webserver_sg"
  description = "SSH inbound traffic from Bastion Host"
  vpc_id      = aws_vpc.ttp_vpc.id

  ingress {
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.ttp_pb_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.ttp_web_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "ttp_web_sg" {
  name        = "3tp_web_sg"
  description = "Allow HTTP"
  vpc_id      = aws_vpc.ttp_vpc.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

