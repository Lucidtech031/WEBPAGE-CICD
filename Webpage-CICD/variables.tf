variable "aws_region" {
    description = "AWS region"
    type = string
    default = "us-east-2"
}

variable "project_name" {
    description = "Name of the project"
    type = string
    default = "flask-devops"
}

variable "vpc_cidr" {
    description = "CIDR block VPC"
    type = string
    default = "10.80.0.0/16"
}

variable "public_subnet_cidr" {
    description = "CIDR block public subnet"
    type = string
    default = "10.0.1.0/24"
}

variable "ec2_ami" {
    description = "AMI ID for EC2 instance"
    type = string
    default = "ami-0d0f28110d16ee7d6"
}

variable "ec2_instance_type" {
    description = "Instance type for EC2"
    type = string
    default = "t2.micro"
}

variable "key_pair_name" {
    description = "Name of key pair for SSH access"
    type = string
    default = "devops-key"
}