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
    egress {
  from_port   = 0
  to_port     = 0
  protocol    = "-1"
  cidr_blocks = ["0.0.0.0/0"]
}

       
  tags = {
    Name = "TerraformSG"
  }
}


resource "aws_s3_bucket" "terraformBucket" {
  bucket = "terraformpactiseucketmnbvcxzlkjhgfdsa"
 
  tags = {
    Name        = "TerraformBucket"
    Environment = "Dev"
  } 
}


resource "aws_instance" "webs1" {
#   ami = "ami-020cba7c55df1f615"
ami = "ami-053b0d53c279acc90" # Ubuntu 24.04 LTS

  instance_type = "t2.micro"
  vpc_security_group_ids = [aws_security_group.sgTerraform.id]
    subnet_id = aws_subnet.sub1.id

  user_data                   = file("${path.module}/data.sh")

}

output "file" {
  value = file("data.sh")
  
}

resource "aws_instance" "webs2" {
#   ami = "ami-020cba7c55df1f615"
ami = "ami-053b0d53c279acc90" # Ubuntu 24.04 LTS

  instance_type = "t2.micro"
  vpc_security_group_ids = [aws_security_group.sgTerraform.id]
    subnet_id = aws_subnet.sub2.id

    # user_data_base64 =  base64encode(file("data.sh"))
    user_data                   = file("${path.module}/data.sh")
}


resource "aws_lb" "practiseELB" {
  name               = "practise-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.sgTerraform.id]
  subnets            = [aws_subnet.sub1.id, aws_subnet.sub2.id]

  tags = {
    Name = "PractiseALB"
  }
}
resource "aws_lb_target_group" "websTG" {
  name     = "webs-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.practiseVpc.id

  health_check {
    path                = "/"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
}   
resource "aws_lb_target_group_attachment" "webs1TG" {
  target_group_arn = aws_lb_target_group.websTG.arn
  target_id        = aws_instance.webs1.id
  port             = 80
}
resource "aws_lb_target_group_attachment" "webs2TG" {
  target_group_arn = aws_lb_target_group.websTG.arn
  target_id        = aws_instance.webs2.id
  port             = 80
}

resource "aws_lb_listener" "Listener" {
    load_balancer_arn = aws_lb.practiseELB.arn
    port              = 80
    protocol          = "HTTP"
    
    default_action {
        type             = "forward"
        target_group_arn = aws_lb_target_group.websTG.arn
    }
  
}   