provider "aws" {
  region  = "ap-northeast-2"
  # 2.x 버전의 AWS 공급자 허용
  version = "~> 2.0"
}


# vpc 생성
resource "aws_vpc" "VPC_GeC_IDC" {
  cidr_block           = var.cidr_block
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags = {
    Name = "VPC_${var.tag_name}"
  }
}

# IGW
resource "aws_internet_gateway" "VPC_GeC_IDC_IGW" {
  vpc_id = aws_vpc.VPC_GeC_IDC.id
  tags = {
    Name = "IGW_${var.tag_name}"
  }
}

# resource "aws_internet_gateway_attachment" "igw_attach" {
#   vpc_id              = aws_vpc.VPC_GeC_IDC.id
#   internet_gateway_id = aws_internet_gateway.VPC_GeC_IDC_IGW
# }

# 라우트 테이블
resource "aws_route_table" "VPC_GeC_IDC_RT" {
  vpc_id = aws_vpc.VPC_GeC_IDC.id
  route {
    cidr_block = var.rt_cidr
    gateway_id = aws_internet_gateway.VPC_GeC_IDC_IGW.id
  }
  tags = {
    Name = "VPC_${var.tag_name}_RT"
  }
}

#
resource "aws_route" "IDCRout_1" {
  route_table_id         = aws_route_table.VPC_GeC_IDC_RT.id
  destination_cidr_block = var.IDCRout_1
  gateway_id             = aws_internet_gateway.VPC_GeC_IDC_IGW.id
  depends_on             = [var.rt_id]
}

# cgw route
resource "aws_route" "IDCRout_2" {
  route_table_id         = aws_route_table.VPC_GeC_IDC_RT.id
  destination_cidr_block = var.IDCRout_2
  instance_id            = aws_instance.IDC_Gec_CGW.id
  depends_on             = [var.instance_cgw_id]
}

# 라우트 테이블 서브넷 연결
resource "aws_route_table_association" "IDCSubnetRTAssociation" {
  subnet_id      = aws_subnet.subnet.id
  route_table_id = aws_route_table.VPC_GeC_IDC_RT.id
}

# 서브넷
resource "aws_subnet" "subnet" {
  vpc_id                  = aws_vpc.VPC_GeC_IDC.id
  cidr_block              = var.subnet
  availability_zone       = var.subnet_zone
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.tag_name}_subnet"
  }
}
