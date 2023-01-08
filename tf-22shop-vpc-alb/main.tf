# ALB
resource "aws_alb" "WEB" {
  name                             = "WEB-ALB"
  internal                         = false
  load_balancer_type               = "application"
  security_groups                  = [ aws_security_group.ALB.id ]
  subnets                          = [ aws_subnet.VPC_WEB_public_1a.id , aws_subnet.VPC_WEB_public_1c.id ]
  enable_cross_zone_load_balancing = true
}
resource "aws_alb_target_group" "WEB" {
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
    healthy_threshold =3
    unhealthy_threshold =3
  }
}
resource "aws_alb_target_group_attachment" "WEBInstance01" {
  target_group_arn = aws_alb_target_group.WEB.arn
  target_id = aws_instance.WEBEC201.id
  port = 80
}
resource "aws_alb_target_group_attachment" "WEBInstance02" {
  target_group_arn = aws_alb_target_group.WEB.arn
  target_id = aws_instance.WEBEC202.id
  port = 80
}
resource "aws_alb_listener" "WEB" {
  load_balancer_arn = aws_alb.WEB.arn
  port              = 80
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_alb_target_group.WEB.arn
  }
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
