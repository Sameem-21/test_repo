#creating terraform
terraform{
    required_providers{
        aws = {
            source  = "hashicorp/aws"
            version = "~> 6.0"
        }
    }
}
#provider info
provider "aws"{
    region= "ap-south-1"
}

#VPC creation

resource "aws_vpc" "test_vpc"{
    cidr_block = "10.0.0.0/16"
  lifecycle {
      create_before_destroy= true
    }
    tags={
        name= "test_vpc"
    }
}

#subnet creation
resource "aws_subnet" "test_subnet"{
    vpc_id            = aws_vpc.test_vpc.id
    cidr_block        = "10.0.5.0/24"
    availability_zone = "ap-south-1a"
    
    tags={
        Name= "test_subnet"
    }
}

#internet gateway creation
resource "aws_internet_gateway" "test_igw"{
    vpc_id = aws_vpc.test_vpc.id

    tags={
        Name= "test_igw"
    }
}
#route table creation
resource "aws_route_table" "test_route_table"{
    vpc_id = aws_vpc.test_vpc.id
    route{
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.test_igw.id
    }

    tags={
        Name= "test_route_table"
    }
}

resource "aws_route_table_association" "test_route_table_association"{
    subnet_id      = aws_subnet.test_subnet.id
    route_table_id = aws_route_table.test_route_table.id
}

#security group creation
resource "aws_security_group" "test_sg"{
    name        = "test_sg"
    description = "allow ssh and http"
    vpc_id      = aws_vpc.test_vpc.id

    ingress{
        from_port   = 22
        to_port     = 22
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    ingress{
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
    
    
    egress{
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
}
#EC2 instance creation

data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical's AWS account ID

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }
}

resource "aws_instance" "test_instance"{
    instance_type = "t3.micro"
    ami           = data.aws_ami.ubuntu.id #Amazon Linux 2 AMI (HVM), SSD Volume Type for ap-south-1
    subnet_id     = aws_subnet.test_subnet.id
    security_groups = [aws_security_group.test_sg.name]
    associate_public_ip_address = true
    tags={
        Name= "test_instance"
    }
}