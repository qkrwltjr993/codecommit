provider "aws" {
  region  = "ap-northeast-2"
  # 2.x 버전의 AWS 공급자 허용
  version = "~> 2.0"
}

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

# 보안그룹 생성 
resource "aws_security_group" "WEB" {
  name = "${var.cluster_name}-WEB"
  description = "Allow all HTTP"
  vpc_id = aws_vpc.VPC_WEB.id

}
resource "aws_security_group_rule" "allow_sever_http_inbound" {
  type = "ingress"
  security_group_id = aws_security_group.instance.id

  from_port = 8080
  to_port = 8080
  protocol = local.tcp_protocol #"tcp"
  cidr_blocks = ["0.0.0.0/0"]
}
resource "aws_security_group_rule" "allow_sever_ssh_inbound" {
  type = "ingress"
  security_group_id = aws_security_group.instance.id

  from_port = "22"
  to_port = "22"
  protocol = local.tcp_protocol #"tcp"
  cidr_blocks = ["0.0.0.0/0"]
}
resource "aws_security_group_rule" "allow_sever_ICMP_inbound" {
  type = "ingress"
  security_group_id = aws_security_group.instance.id

  from_port = "-1"
  to_port = "-1"
  protocol = "ICMP"
  cidr_blocks = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "allow_sever_outbound" {
  type = "egress"
  security_group_id = aws_security_group.instance.id

  from_port = 0
  to_port = 0
  protocol = "-1"
  cidr_blocks = ["0.0.0.0/0"]
}


# ALB 보안그룹
resource "aws_security_group" "ALB" {
  name = "${var.cluster_name}-WEB"
  description = "Allow all HTTP"
  vpc_id = aws_vpc.VPC_WEB.id

}
resource "aws_security_group_rule" "allow_http_inbound" {
  type              = "ingress"
  security_group_id = aws_security_group.ALB.id

  from_port   = local.http_port
  to_port     = local.http_port
  protocol    = local.tcp_protocol
  cidr_blocks = local.all_ips
}
resource "aws_security_group_rule" "allow_all_outbound" {
  type              = "egress"
  security_group_id = aws_security_group.ALB.id

  from_port   = local.any_port
  to_port     = local.any_port
  protocol    = local.any_protocol
  cidr_blocks = local.all_ips
}

# ALB
resource "aws_alb" "ALB" {
  name                             = "WEB-alb"
  internal                         = false
  load_balancer_type               = "application"
  security_groups                  = [ aws_security_group.ALB.id ]
  subnets                          = [ aws_subnet.VPC_WEB_public_1a.id , aws_subnet.VPC_WEB_public_1c.id ]
  enable_cross_zone_load_balancing = true
}
resource "aws_alb_target_group" "ALBTG" {
  name = "WEB-ALB-TG"
  port = 8080
  protocol = "HTTP"
  vpc_id = aws_vpc.VPC_WEB.id
  health_check {
    path = "/"
    protocol = "HTTP"
    matcher = "200"
    interval = 10
    timeout = 5
    healthy_threshold = 3
    unhealthy_threshold = 3
  }
}
resource "aws_alb_target_group_attachment" "WEBInstance01" {
  target_group_arn = aws_alb_target_group.ALBTG.arn
  target_id = aws_instance.WEBEC201.id
  port = 80
}
resource "aws_alb_target_group_attachment" "WEBInstance02" {
  target_group_arn = aws_alb_target_group.ALBTG.arn
  target_id = aws_instance.WEBEC202.id
  port = 80
}
resource "aws_alb_listener" "ALBL" {
  load_balancer_arn = aws_alb.ALB.arn
  port              = 80
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_alb_target_group.ALBTG.arn
  }
}
# NAT 
resource "aws_eip" "nat_ip" {
  vpc   = true

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_nat_gateway" "nat_gateway" {
  allocation_id = aws_eip.nat_ip.id

  subnet_id = aws_subnet.VPC_WEB_public_1A.id

  tags = {
    Name = "NAT_gateway"
  }
}

# instance
resource "aws_instance" "WEBEC201" {
  ami = "ami-035233c9da2fabf52"
  instance_type = "t2.micro"
  vpc_security_group_ids = [ 
    aws_security_group.instance.id
   ]
  subnet_id = aws_subnet.VPC_WEB_public_1a.id
  associate_public_ip_address = "true"
  key_name = "sol"
  user_data = <<-EOF
  #!/bin/bash
  hostname ELB-EC2-1
  yum install httpd -y
  yum install net-snmp net-snmp-utils -y
  yum install tcpdump -y
  service httpd start
  chkconfig httpd on
  service snmpd start
  chkconfig snmpd on
  echo "<h1>ELB-EC2-1 Web Server</h1>" > /var/www/html/index.html
    
  EOF
 
  tags = {
    "Name" = "VPC_WEB_public_ec2-1"
  }
}
resource "aws_instance" "WEBEC201" {
  ami                         = "ami-035233c9da2fabf52"
  instance_type               = "t2.micro"
  vpc_security_group_ids      = [ 
    aws_security_group.instance.id
   ]
  subnet_id                   = aws_subnet.VPC_WEB_public_1c.id
  associate_public_ip_address = "true"
  key_name               = "sol"
  user_data = <<-EOF
  #!/bin/bash
  hostname ELB-EC2-1
  yum install httpd -y
  yum install net-snmp net-snmp-utils -y
  yum install tcpdump -y
  service httpd start
  chkconfig httpd on
  service snmpd start
  chkconfig snmpd on
  echo "<h1>ELB-EC2-2 Web Server222</h1>" > /var/www/html/index.html
    
  EOF
        
  tags = {
    "Name" = "VPC_WEB_public_ec2-2"
  }
}





































############################################IDC######################3



# IDC VPC 생성
resource "aws_vpc" "VPC_IDC" {
  cidr_block       = "10.2.0.0/16"
  #instance_tenancy = "default"

  # 인스턴스에 public DNS가 표시되도록 하는 속성
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "VPC_IDC"
  }
}

# IDC Public 서브넷 생성
resource "aws_subnet" "VPC_IDC_public_1a" {
  vpc_id            = aws_vpc.VPC_IDC.id
  cidr_block        = "10.2.1.0/24"
  availability_zone = "ap-northeast-2a"

  tags = {
    Name = "VPC_IDC_public_1A"
  }
}
resource "aws_subnet" "VPC_IDC_public_1c" {
  vpc_id            = aws_vpc.VPC_IDC.id
  cidr_block        = "10.2.2.0/24"
  availability_zone = "ap-northeast-2c"

  tags = {
    Name = "VPC_IDC_public_1C"
  }
}

# 인터넷 게이트웨이 생성 후 VPC-IDC에 연결
resource "aws_internet_gateway" "VPC_IDC_IGW" {
  vpc_id = aws_vpc.VPC_IDC.id

  tags = {
    Name = "VPC_IDC_IGW"
  }
}

# IDC 라우팅 테이블 생성 후 igw에 연결
resource "aws_route_table" "VPC_IDC_RT" {
  vpc_id = aws_vpc.VPC_IDC.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.VPC_IDC_IGW.id
  }
  tags = {
    Name = "VPC_IDC_RT"
  }
}

# 서브넷과 라우팅 테이블 연결
resource "aws_route_table_association" "VPC_IDC_public_1a" {
  subnet_id      = aws_subnet.VPC_IDC_public_1a.id
  route_table_id = aws_route_table.VPC_IDC_RT.id
}
resource "aws_route_table_association" "VPC_IDC_public_1c" {
  subnet_id      = aws_subnet.VPC_IDC_public_1c.id
  route_table_id = aws_route_table.VPC_IDC_RT.id
}