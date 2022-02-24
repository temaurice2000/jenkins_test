provider "aws" {
  region = var.regional 
}
variable "regional" {}
variable "vpc_cidr_block" {}
variable "Public_subnet_cidr_block" {}
variable "Private_subnet_cidr_block" {}
variable "avail_zone1" {}
variable "avail_zone2" {}
variable "env" {}

resource "aws_vpc" "Ansible_vpc" {
  cidr_block = var.vpc_cidr_block
  
  tags = {
    Name : "${var.env}-vpc"
  }
}

resource "aws_subnet" "Public_subnet" {
  cidr_block = var.Public_subnet_cidr_block
  tags = {
    Name : "${var.env}-pub_subnet"
  }
  vpc_id = aws_vpc.Ansible_vpc.id    
  availability_zone = var.avail_zone1
}
resource "aws_subnet" "Private_subnet" {
  cidr_block = var.Private_subnet_cidr_block
  tags = {
    Name : "${var.env}-private_subnet"
  }
  vpc_id = aws_vpc.Ansible_vpc.id  
  availability_zone = var.avail_zone2
}
resource "aws_route_table" "public_RT" {
  vpc_id = aws_vpc.Ansible_vpc.id  
  route  {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.Ansible_IGW.id  
  }
}
resource "aws_route_table" "private_RT" {
  vpc_id = aws_vpc.Ansible_vpc.id  
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.Ansible_NATGW.id  
  }
}
resource "aws_route_table_association" "pub_rt_ass" {
  subnet_id = aws_subnet.Public_subnet.id  
  route_table_id = aws_route_table.public_RT.id  
}
resource "aws_route_table_association" "pri_rt_ass" {
  subnet_id = aws_subnet.Private_subnet.id  
  route_table_id = aws_route_table.private_RT.id  
}
resource "aws_internet_gateway" "Ansible_IGW" {
  vpc_id = aws_vpc.Ansible_vpc.id
  tags = {
    Name : "${var.env}-IGW"
  }
}
resource "aws_nat_gateway" "Ansible_NATGW" {
  subnet_id     = aws_subnet.Public_subnet.id
  allocation_id = aws_eip.Ansible-eip.id
}
resource "aws_eip" "Ansible-eip" {
  vpc = true
  tags = {
    Name : "${var.env}-eip"
  }
}
resource "aws_instance" "Ansible_master" {
  ami             = "ami-01f87c43e618bf8f0"
  instance_type   = "t2.micro"
  subnet_id       = aws_subnet.Public_subnet.id
  security_groups = [aws_security_group.public-SG.id]
  key_name        = "ansible_key_pair"
  tags = {
    Name : "${var.env}-Master"
  }
  associate_public_ip_address = true
}
resource "aws_instance" "Ansible_slave1" {
  ami             = "ami-01f87c43e618bf8f0"
  instance_type   = "t2.micro"
  subnet_id       = aws_subnet.Public_subnet.id
  security_groups = [aws_security_group.public-SG.id]
  key_name        = "ansible_key_pair"
  tags = {
    Name : "${var.env}-first_slave"
  }
  associate_public_ip_address = true
}
resource "aws_instance" "Ansible_slave2" {
  ami             = "ami-01f87c43e618bf8f0"
  instance_type   = "t2.micro"
  subnet_id       = aws_subnet.Private_subnet.id
  security_groups = [aws_security_group.private-SG.id]
  key_name        = "ansible_key_pair"
  tags = {
    Name : "${var.env}-second_slave"
  }
}
resource "aws_instance" "Ansible_slave3" {
  ami             = "ami-01f87c43e618bf8f0"
  instance_type   = "t2.micro"
  subnet_id       = aws_subnet.Private_subnet.id
  security_groups = [aws_security_group.private-SG.id]
  key_name        = "ansible_key_pair"
  tags = {
    Name : "${var.env}-third_slave"
  }
}
resource "aws_security_group" "public-SG" {
  name        = "Allow_SSH"
  description = "allow ssh inbound traffic from the internet"
  vpc_id      = aws_vpc.Ansible_vpc.id
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name : "${var.env}-Pub_SG"
  }
}
resource "aws_security_group" "private-SG" {
  name        = "allow ssh"
  description = "allow ssh from public subnet"
  vpc_id      = aws_vpc.Ansible_vpc.id
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr_block]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.vpc_cidr_block]
  }
  tags = {
    Name : "${var.env}-Pri_SG"
  }
}