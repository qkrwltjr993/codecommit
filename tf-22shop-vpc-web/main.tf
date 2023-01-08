# WEB VPC 생성
resource "aws_vpc" "VPC_WEB" {
  cidr_block       = "10.1.0.0/16"
  #instance_tenancy = "default"

  # 인스턴스에 public DNS가 표시되도록 하는 속성
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "VPC_WEB"
  }
}

# WEB Public 서브넷 생성
resource "aws_subnet" "VPC_WEB_public_1a" {
  vpc_id            = aws_vpc.VPC_WEB.id
  cidr_block        = "10.1.1.0/24"
  availability_zone = "ap-northeast-2a"

  tags = {
    Name = "VPC_WEB_public_1A"
  }
}
resource "aws_subnet" "VPC_WEB_public_1c" {
  vpc_id            = aws_vpc.VPC_WEB.id
  cidr_block        = "10.1.2.0/24"
  availability_zone = "ap-northeast-2c"

  tags = {
    Name = "VPC_WEB_public_1C"
  }
}



# 인터넷 게이트웨이 생성 후 VPC-WEB에 연결
resource "aws_internet_gateway" "VPC_WEB_IGW" {
  vpc_id = aws_vpc.VPC_WEB.id

  tags = {
    Name = "VPC_WEB_IGW"
  }
}

# WEB 라우팅 테이블 생성 후 igw에 연결
resource "aws_route_table" "VPC_WEB_RT" {
  vpc_id = aws_vpc.VPC_WEB.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.VPC_WEB_IGW.id
  }
  tags = {
    Name = "VPC_WEB_RT"
  }
}

# 서브넷과 라우팅 테이블 연결
resource "aws_route_table_association" "VPC_WEB_public_1a" {
  subnet_id      = aws_subnet.VPC_WEB_public_1a.id
  route_table_id = aws_route_table.VPC_WEB_RT.id
}
resource "aws_route_table_association" "VPC_WEB_public_1c" {
  subnet_id      = aws_subnet.VPC_WEB_public_1c.id
  route_table_id = aws_route_table.VPC_WEB_RT.id
}

