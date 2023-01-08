# instance
resource "aws_instance" "WEBEC201" {
  ami                    = "ami-0b5eea76982371e91"
  instance_type          = "t2.micro"
  vpc_security_group_ids = [ 
    aws_security_group.instance.id
   ]
  subnet_id                   = aws_subnet.VPC_WEB_public_1a.id
  associate_public_ip_address = "true"
  key_name                    = "sol"
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
resource "aws_instance" "WEBEC202" {
  ami                         = "ami-0b5eea76982371e91"
  instance_type               = "t2.micro"
  vpc_security_group_ids      = [ 
    aws_security_group.instance.id
   ]
  subnet_id                   = aws_subnet.VPC_WEB_public_1c.id
  associate_public_ip_address = "true"
  key_name               = "soldesk"
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
