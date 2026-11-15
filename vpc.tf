
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# ==========================================
# AWS PROVIDER
# ==========================================

provider "aws" {
  region = "ap-southeast-1"
}

# ==========================================
# VPC
# ==========================================

resource "aws_vpc" "demo_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name        = "demo-vpc"
    Environment = "Development"
    ManagedBy   = "Terraform"
  }
}

# ==========================================
# PUBLIC SUBNET
# ==========================================

resource "aws_subnet" "public_subnet" {
  vpc_id                  = aws_vpc.demo_vpc.id
  cidr_block              = "10.0.0.0/24"
  map_public_ip_on_launch = true

  tags = {
    Name = "public-subnet"
    Type = "Public"
  }
}

# ==========================================
# PRIVATE SUBNET
# ==========================================

resource "aws_subnet" "private_subnet" {
  vpc_id     = aws_vpc.demo_vpc.id
  cidr_block = "10.0.1.0/24"

  tags = {
    Name = "private-subnet"
    Type = "Private"
  }
}

# ==========================================
# INTERNET GATEWAY
# ==========================================

resource "aws_internet_gateway" "demo_igw" {
  vpc_id = aws_vpc.demo_vpc.id

  tags = {
    Name = "demo-igw"
  }
}

# ==========================================
# PUBLIC ROUTE TABLE
# ==========================================

resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.demo_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.demo_igw.id
  }

  tags = {
    Name = "public-route-table"
  }
}

# ==========================================
# PRIVATE ROUTE TABLE
# ==========================================

resource "aws_route_table" "private_rt" {
  vpc_id = aws_vpc.demo_vpc.id

  tags = {
    Name = "private-route-table"
  }
}

# ==========================================
# PUBLIC SUBNET ASSOCIATION
# ==========================================

resource "aws_route_table_association" "public_association" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public_rt.id
}

# ==========================================
# PRIVATE SUBNET ASSOCIATION
# ==========================================

resource "aws_route_table_association" "private_association" {
  subnet_id      = aws_subnet.private_subnet.id
  route_table_id = aws_route_table.private_rt.id
}
