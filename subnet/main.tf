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
