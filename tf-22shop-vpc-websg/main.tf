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
