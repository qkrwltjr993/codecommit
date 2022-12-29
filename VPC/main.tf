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
