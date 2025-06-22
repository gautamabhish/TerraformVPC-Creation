resource "aws_vpc" "practiseVpc"{
    cidr_block = var.cidr
  tags = {
    Name = "PractiseVPC"
  }
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

resource "aws_security_group" "sgTerraform" {
    name = "terraform_sg"
    description = "Security group for TerraformVPC"
    vpc_id = aws_vpc.practiseVpc.id

    ingress {
      description = "Allow SSH"
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }

    ingress {

        description = "Allow HTTP"
        from_port   = 80        
        to_port     = 80
        protocol    = "tcp"
        cidr_blocks = [ "0.0.0.0/0" ]
    }
    
       
  tags = {
    Name = "TerraformSG"
  }
}


resource "aws_s3_bucket" "terraformBucket" {
  bucket = "terraform-bucket-abhishekGautam-098gh"
 
  tags = {
    Name        = "TerraformBucket"
    Environment = "Dev"
  } 
}

resource "aws_s3_bucket_acl" "aws3BucketACL" {
  bucket = aws_s3_bucket.terraformBucket.id
  acl    = "public-read"
#   depends_on = [ aws_s3_bucket. ]
  
}


resource "aws_instance" "webs1" {
  ami = "ami-020cba7c55df1f615"
  instance_type = "t2.micro"
  vpc_security_group_ids = [aws_security_group.sgTerraform.id]
    subnet_id = aws_subnet.sub1.id

    user_data_base64 = base64encode(file("data.sh"))
}

resource "aws_instance" "webs2" {
  ami = "ami-020cba7c55df1f615"
  instance_type = "t2.micro"
  vpc_security_group_ids = [aws_security_group.sgTerraform.id]
    subnet_id = aws_subnet.sub2.id

    user_data_base64 =  base64encode(file("data.sh"))
}


