##To create the VPC

resource "aws_vpc" "my-vpc" {
    cidr_block = var.vpc_cidr
    enable_dns_hostnames = true
    enable_dns_support = true
    tags = {
        Name = "3-tier-vpc"
    }
  
}

##To Create IGW for Public Subnets

resource "aws_internet_gateway" "igw" {
    vpc_id = aws_vpc.my-vpc.id
    tags = {
      Name = "3-tier-IGW"
    }
  
}

##To create NAT Gateway for Private Subnets

resource "aws_eip" "nat" {
    domain = "vpc"

}

resource "aws_nat_gateway" "nat_gw" {
    allocation_id = aws_eip.nat.id
    subnet_id = aws_subnet.dmz[0].id
    tags = {
      Name = "3-tier-NGW"
    }
  
}

##To Create Route Tables

resource "aws_route_table" "public" {
    vpc_id = aws_vpc.my-vpc.id
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.igw.id
    }
    tags = {
        Name = "3-tier-public-route-table"
    }
  
}

resource "aws_route_table" "private" {
    vpc_id = aws_vpc.my-vpc.id
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_nat_gateway.nat_gw.id
    }
    tags = {
        Name = "3-tier-private-route-table"
    }
  
}

##To Create Subnets

resource "aws_subnet" "dmz" {
    count = length(var.dmz_subnet_cidrs)
    vpc_id = aws_vpc.my-vpc.id
    cidr_block = element(var.dmz_subnet_cidrs,count.index)
    map_public_ip_on_launch = true
    availability_zone = var.region
    tags = {
      Name = "dmz-subnet-${count.index}"
    }
  
}

resource "aws_subnet" "web" {
    count = length(var.web_subnet_cidrs)
    vpc_id = aws_vpc.my-vpc.id
    cidr_block = element(var.web_subnet_cidrs,count.index)
    tags = {
      Name = "web-subnet-${count.index}"
    }
}

resource "aws_subnet" "app" {
    count = length(var.app_subnet_cidrs)
    vpc_id = aws_vpc.my-vpc.id
    cidr_block = element(var.app_subnet_cidrs,count.index)
    tags = {
        Name = "app-subnet-${count.index}"
    }
  
}

resource "aws_subnet" "db" {
    count = length(var.db_subnet_cidrs)
    vpc_id = aws_vpc.my-vpc.id
    cidr_block = element(var.db_subnet_cidrs,count.index)
    tags = {
        Name = "db-subnet-${count.index}"
    }
  
}

##Associate Subnets with Route Tables

resource "aws_route_table_association" "dmz" {
    count = length(aws_subnet.dmz)
    subnet_id = element(aws_subnet.dmz.*.id, count.index)
    route_table_id = aws_route_table.public.id
  
}

resource "aws_route_table_association" "web" {
  count = length(aws_subnet.web)
  subnet_id = element(aws_subnet.web.*.id, count.index)
  route_table_id = aws_route_table.private.id
}

resource "aws_route_table_association" "app" {
    count = length(aws_subnet.app)
    subnet_id = element(aws_subnet.app.*.id, count.index)
    route_table_id = aws_route_table.private.id
  
}

resource "aws_route_table_association" "db" {
    count = length(aws_subnet.db)
    subnet_id = element(aws_subnet.db.*.id, count.index)
    route_table_id = aws_route_table.private.id
  
}

##Create Security Groups for EC2

resource "aws_security_group" "web_sg" {
    vpc_id = aws_vpc.my-vpc.id
    ingress {
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
    tags = {
        Name = "web-sg"
    }
  
}

##Creating EC2 instance in web subnet

resource "aws_instance" "web-instance" {
    ami = "ami-0e2ff28bfb72a4e45"
    instance_type = "t2.micro"
    subnet_id = aws_subnet.web[0].id
    private_ip = "10.0.3.10"
    security_groups = [aws_security_group.web_sg.id]

    metadata_options {
      http_tokens = "required"
    }

    #To install apache 
    user_data = <<-EOF
                #!/bin/bash
                yum update -y
                yum install -y httpd
                systemctl start httpd
                systemctl enable httpd
            EOF
    tags = {
      Name = "3-tier-web-ec2"
    }
  
}

