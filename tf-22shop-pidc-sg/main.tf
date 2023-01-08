#보안그룹
resource "aws_security_group" "sg" {
  description = "aws_security_group"
  name        = var.security_group_name
  vpc_id      = aws_vpc.VPC_GeC_IDC.id
}

# 보안그룹 룰s
resource "aws_security_group_rule" "allow_sever_http_inbound" {
  type              = var.security_group_rule_type
  security_group_id = aws_security_group.sg.id

  from_port   = "8080"
  to_port     = "8080"
  protocol    = var.sg_protocol_tcp
  cidr_blocks = [var.sg_cidr_blocks]
}
resource "aws_security_group_rule" "allow_sever_ssh_inbound" {
  type              = var.security_group_rule_type
  security_group_id = aws_security_group.sg.id

  from_port   = "22"
  to_port     = "22"
  protocol    = var.sg_protocol_tcp
  cidr_blocks = [var.sg_cidr_blocks]
}
resource "aws_security_group_rule" "allow_sever_icmp_inbound" {
  type              = var.security_group_rule_type
  security_group_id = aws_security_group.sg.id

  from_port   = "-1"
  to_port     = "-1"
  protocol    = var.sg_protocol_tcp
  cidr_blocks = [var.sg_cidr_blocks]
}
resource "aws_security_group_rule" "allow_sever_dns_tcp_inbound" {
  type              = var.security_group_rule_type
  security_group_id = aws_security_group.sg.id

  from_port   = "53"
  to_port     = "53"
  protocol    = var.sg_protocol_tcp
  cidr_blocks = [var.sg_cidr_blocks]
}
resource "aws_security_group_rule" "allow_sever_dns_udp_inbound" {
  type              = var.security_group_rule_type
  security_group_id = aws_security_group.sg.id

  from_port   = "53"
  to_port     = "53"
  protocol    = var.sg_protocol_udp
  cidr_blocks = [var.sg_cidr_blocks]
}
resource "aws_security_group_rule" "allow_sever_https_inbound" {
  type              = var.security_group_rule_type
  security_group_id = aws_security_group.sg.id

  from_port   = "443"
  to_port     = "443"
  protocol    = var.sg_protocol_tcp
  cidr_blocks = [var.sg_cidr_blocks]
}
resource "aws_security_group_rule" "allow_sever_outbound" {
  type              = var.security_group_rule_type_1
  security_group_id = aws_security_group.sg.id

  from_port   = 0
  to_port     = 0
  protocol    = "-1"
  cidr_blocks = [var.sg_cidr_blocks]
}
