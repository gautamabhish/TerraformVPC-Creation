resource "aws_vpc" "practiseVpc"{

    cidr_block = var.cidr
}


resource "aws_subnet" "sub1" {
  vpc_id = aws_vpc.practiseVpc.id
  cidr_block = "10.0.0.0/24"
    availability_zone = "us-east-1a"
    map_public_ip_on_launch = true
}

resource "aws_subnet" "sub2" {
  vpc_id = aws_vpc.practiseVpc.id
  cidr_block = "10.0.1.0/24"
    availability_zone = "us-east-1b" 
    map_public_ip_on_launch = true
}

resource "aws_internet_gateway" "internetGateway" {
    vpc_id = aws_vpc.practiseVpc.id
  
}

resource "aws_route_table" "RT" {
    vpc_id = aws_vpc.practiseVpc.id
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.internetGateway.id
    }
  
}


resource "aws_route_table_association" "sub1RTA" {
    subnet_id = aws_subnet.sub1.id
    route_table_id = aws_route_table.RT.id
}

resource "aws_route_table_association" "sub2RTA" {
    subnet_id = aws_subnet.sub2.id
    route_table_id = aws_route_table.RT.id
}