terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

provider "aws" {
  region = var.region
}

resource "aws_vpc" "techcorp_vpc" {
  cidr_block           = "10.0.0.0/16"
  instance_tenancy     = "default"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "techcorp-vpc"
  }
}

resource "aws_subnet" "techcorp_public_subnet_1" {
  vpc_id                  = aws_vpc.techcorp_vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "eu-west-1a"
  map_public_ip_on_launch = true

  tags = {
    Name = "techcorp-public-subnet-1"
  }
}

resource "aws_subnet" "techcorp_public_subnet_2" {
  vpc_id                  = aws_vpc.techcorp_vpc.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "eu-west-1b"
  map_public_ip_on_launch = true

  tags = {
    Name = "techcorp-public-subnet-2"
  }
}

resource "aws_subnet" "techcorp_private_subnet_1" {
  vpc_id            = aws_vpc.techcorp_vpc.id
  cidr_block        = "10.0.3.0/24"
  availability_zone = "eu-west-1a"

  tags = {
    Name = "techcorp-private-subnet-1"
  }
}

resource "aws_subnet" "techcorp_private_subnet_2" {
  vpc_id            = aws_vpc.techcorp_vpc.id
  cidr_block        = "10.0.4.0/24"
  availability_zone = "eu-west-1b"

  tags = {
    Name = "techcorp-private-subnet-2"
  }
}

resource "aws_internet_gateway" "techcorp_igw" {
  vpc_id = aws_vpc.techcorp_vpc.id

  tags = {
    Name = "techcorp-igw"
  }
}

resource "aws_eip" "nat_eip_1" {
  domain     = "vpc"
  depends_on = [aws_internet_gateway.techcorp_igw]

  tags = {
    Name = "techcorp-nat-eip-1"
  }
}

resource "aws_eip" "nat_eip_2" {
  domain     = "vpc"
  depends_on = [aws_internet_gateway.techcorp_igw]

  tags = {
    Name = "techcorp-nat-eip-2"
  }
}

resource "aws_nat_gateway" "natgateway_1" {
  allocation_id = aws_eip.nat_eip_1.id
  subnet_id     = aws_subnet.techcorp_public_subnet_1.id
  depends_on    = [aws_internet_gateway.techcorp_igw]

  tags = {
    Name = "natgateway-1"
  }
}

resource "aws_nat_gateway" "natgateway_2" {
  allocation_id = aws_eip.nat_eip_2.id
  subnet_id     = aws_subnet.techcorp_public_subnet_2.id
  depends_on    = [aws_internet_gateway.techcorp_igw]

  tags = {
    Name = "natgateway-2"
  }
}

resource "aws_route_table" "techcorp_public_rt" {
  vpc_id = aws_vpc.techcorp_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.techcorp_igw.id
  }

  tags = {
    Name = "techcorp-public-rt"
  }
}

resource "aws_route_table" "techcorp_private_rt_1" {
  vpc_id = aws_vpc.techcorp_vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.natgateway_1.id
  }

  tags = {
    Name = "techcorp-private-rt-1"
  }
}

resource "aws_route_table" "techcorp_private_rt_2" {
  vpc_id = aws_vpc.techcorp_vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.natgateway_2.id
  }

  tags = {
    Name = "techcorp-private-rt-2"
  }
}

resource "aws_route_table_association" "public_subnet_1_association" {
  subnet_id      = aws_subnet.techcorp_public_subnet_1.id
  route_table_id = aws_route_table.techcorp_public_rt.id
}

resource "aws_route_table_association" "public_subnet_2_association" {
  subnet_id      = aws_subnet.techcorp_public_subnet_2.id
  route_table_id = aws_route_table.techcorp_public_rt.id
}

resource "aws_route_table_association" "private_subnet_1_association" {
  subnet_id      = aws_subnet.techcorp_private_subnet_1.id
  route_table_id = aws_route_table.techcorp_private_rt_1.id
}

resource "aws_route_table_association" "private_subnet_2_association" {
  subnet_id      = aws_subnet.techcorp_private_subnet_2.id
  route_table_id = aws_route_table.techcorp_private_rt_2.id
}

resource "aws_security_group" "bastion_sg" {
  name        = "bastion-sg"
  description = "Security group for bastion host"
  vpc_id      = aws_vpc.techcorp_vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["${var.my_ipaddress}"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "techcorp-bastion-sg"
  }
}

resource "aws_security_group" "web_sg" {
  name        = "techcorp-web-sg"
  description = "Security group for web servers"
  vpc_id      = aws_vpc.techcorp_vpc.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.bastion_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "techcorp-web-sg"
  }
}

resource "aws_security_group" "database_sg" {
  name        = "techcorp-database-sg"
  description = "Security group for database servers"
  vpc_id      = aws_vpc.techcorp_vpc.id

  ingress {
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.web_sg.id]
  }

  ingress {
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.bastion_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "techcorp-database-sg"
  }
}

resource "aws_instance" "techcorp_bastion_host" {
  ami                    = "ami-0ca708d12ecae12cb"
  instance_type          = var.instance_type_micro
  subnet_id              = aws_subnet.techcorp_public_subnet_1.id
  vpc_security_group_ids = [aws_security_group.bastion_sg.id]
  key_name               = var.keypair_name

  tags = {
    Name = "techcorp-bastion-host"
  }
}

resource "aws_eip" "bastion_eip" {
  instance = aws_instance.techcorp_bastion_host.id
  domain   = "vpc"

  tags = {
    Name = "techcorp-bastion-eip"
  }
}

resource "aws_instance" "techcorp_web_server_1" {
  ami                    = "ami-0ca708d12ecae12cb"
  instance_type          = var.instance_type_micro
  subnet_id              = aws_subnet.techcorp_private_subnet_1.id
  vpc_security_group_ids = [aws_security_group.web_sg.id]
  user_data              = file("user_data/web_server_setup.sh")
  key_name               = var.keypair_name

  tags = {
    Name = "techcorp-webserver-1"
  }
}

resource "aws_instance" "techcorp_web_server_2" {
  ami                    = "ami-0ca708d12ecae12cb"
  instance_type          = var.instance_type_micro
  subnet_id              = aws_subnet.techcorp_private_subnet_2.id
  vpc_security_group_ids = [aws_security_group.web_sg.id]
  user_data              = file("user_data/web_server_setup.sh")
  key_name               = var.keypair_name

  tags = {
    Name = "techcorp-webserver-2"
  }
}

resource "aws_instance" "techcorp_db_server" {
  ami                    = "ami-0ca708d12ecae12cb"
  instance_type          = var.instance_type_small
  subnet_id              = aws_subnet.techcorp_private_subnet_1.id
  vpc_security_group_ids = [aws_security_group.database_sg.id]
  user_data              = file("user_data/db_server_setup.sh")
  key_name               = var.keypair_name

  tags = {
    Name = "techcorp-database-server"
  }
}

resource "aws_lb" "techcorp_alb" {
  name               = "techcorp-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.web_sg.id]
  subnets            = [
    aws_subnet.techcorp_public_subnet_1.id,
    aws_subnet.techcorp_public_subnet_2.id
  ]

  tags = {
    Name = "techcorp-alb"
  }
}

resource "aws_lb_target_group" "techcorp_tg" {
  name     = "techcorp-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.techcorp_vpc.id

  health_check {
    path                = "/"
    protocol            = "HTTP"
    healthy_threshold   = 2
    unhealthy_threshold = 2
    interval            = 30
  }

  tags = {
    Name = "techcorp-tg"
  }
}

resource "aws_lb_target_group_attachment" "web_server_1_attachment" {
  target_group_arn = aws_lb_target_group.techcorp_tg.arn
  target_id        = aws_instance.techcorp_web_server_1.id
  port             = 80
}

resource "aws_lb_target_group_attachment" "web_server_2_attachment" {
  target_group_arn = aws_lb_target_group.techcorp_tg.arn
  target_id        = aws_instance.techcorp_web_server_2.id
  port             = 80
}

resource "aws_lb_listener" "techcorp_listener" {
  load_balancer_arn = aws_lb.techcorp_alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.techcorp_tg.arn
  }
}