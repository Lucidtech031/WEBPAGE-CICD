provider "aws" {
  region = var.aws_region
  }

resource "aws_vpc" "webpage_cicd-app" {
    cidr_block = var.vpc_cidr
    enable_dns_hostnames = true
    tags = {
        Name = "${var.project_name}-vpc"
    }
}

resource "aws_subnet" "public_subnet" {
    vpc_id = aws_vpc.app_vpc.vpc_id
    cidr_block = var.public_subnet_cidr
    availability_zone = "${var.aws_region}a"
    map_public_ip_on_launch = true
    tags = {
        Name = "${var.project_name}-public-subnet"
    }
}

resource "aws_internet_gateway" "igw" {
    vpc_id = aws_vpc.app_vpc.id
    tags = {
        Name = "${var.project_name}-igw"
    }
}

resource "aws_route_table" "public_rt" {
    vpc_id = aws_vpc.app_vpc.id
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.igw.id
    }
    tags = {
        Name = "${var.project_name}-public-rt"
    }
}

resource "aws_security_group" "app_sg" {
    name = "${var.project_name}-sg"
    description = "Allow web ssh traffic"
    vpc_id = aws_vpc.app_vpc.id

    ingress {
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_blocks = "0.0.0.0/0"
    }
    ingress {
        from_port = 443
        to_port = 443
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    ingress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = "10.0.0.244/32"
    }
    ingress {
        from_port = 5000
        to_port = 5000
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
        Name = "${var.project_name}-sg"
    }
}

resource "aws_instance" "app_server" {
    ami = var.ec2_ami
    instance_type = var.ec2_instance_type
    key_name = var.key_pair_name
    subnet_id = aws_subnet.public_subnet.id
    vpc_security_group_ids = [aws_security_group.app_sg.id]

    user_data = <<-EOF
              #!/bin/bash
              # Install Docker
              sudo apt-get update
              sudo apt-get install -y apt-transport-https ca-certificates curl software-properties-common
              curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
              sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
              sudo apt-get update
              sudo apt-get install -y docker-ce
              sudo usermod -aG docker ubuntu
              
              # Install Docker Compose
              sudo curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
              sudo chmod +x /usr/local/bin/docker-compose
              
              # Start Docker service
              sudo systemctl start docker
              sudo systemctl enable docker
              EOF

    tags = {
        Name = "${var.project_name}-server"
    }
}

output "app_instance_public_ip" {
    value = aws_instance.app_server.public_ip
}

