data "aws_caller_identity" "current" {}

locals {
    account_id = data.aws_caller_identity.current.account_id
    region = "eu-central-1"
    service_name_ssm = "com.amazonaws.${local.region}.ssm"
    service_name_ssmmsg = "com.amazonaws.${local.region}.ssmmessages"
    service_name_ec2msg = "com.amazonaws.${local.region}.ec2messages"
    service_name_s3 = "com.amazonaws.${local.region}.s3"   
}

variable "AZ_1a" {
    description = "Default AZ: eu-central-1a"
    type = string
    default = "eu-central-1a"
}

variable "AZ_1b" {
    description = "Default AZ: eu-central-1b"
    type = string
    default = "eu-central-1b"
}

# VPC.tf variables

variable "cidr_vpc" {
    description = "CIDR block for VPC"
    type = string
    default = "10.0.0.0/16"
}

variable "name_vpc" {
    description = "Default name for VPC"
    type = string
    default = "smog_cloud"  
}

variable "cidr_public_subnet1" {
    description = "Default CIDR block for public subnet"
    type = string
    default = "10.0.1.0/24"
}

variable "cidr_public_subnet2" {
    description = "Default CIDR block for public subnet"
    type = string
    default = "10.0.3.0/24"
}

variable "cidr_private_subnet1" {
    description = "Default CIDR block for private subnet"
    type = string
    default = "10.0.2.0/24"
}

variable "cidr_private_subnet2" {
    description = "Default CIDR block for private subnet"
    type = string
    default = "10.0.4.0/24"
}

variable "cidr_internet" {
    description = "Internet CIDR block"
    type = string
    default = "0.0.0.0/0"
}

variable "type_of_endpoint" {
    description = "Use with vpc_endpoint_type if endpoint type is Interface"
    type = string
    default = "Interface"  
}

# ec2.tf variables

variable "os_linux_image" {
    description = "Amazon Linux 3 AMI"
    type = string
    default = "ami-0669b163befffbdfc"
}

variable "EC2_type" {
    description = "Type of EC2 instance: t2.micro "
    type = string
    default = "t2.micro"
}

# EC2 instances User data .sh files

variable "user_data_web_server" {
    description = "Boot file for web servers"
    type = string
    default = "user_data_web_server.sh"
}

variable "user_data_training_instance" {
    description = "Boot file for training instances"
    type = string
    default = "user_data_training_instance.sh"
}