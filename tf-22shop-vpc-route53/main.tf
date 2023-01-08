# Route53 생성
resource "aws_route53_zone" "primary" {
  name = "777aws.ml"
  comment = "777aws.ml"
}

resource "aws_route53_record" "www" {
  zone_id = aws_route53_zone.primary.zone_id
  name    = "777aws.ml"
  type    = "A"
  alias {
    name     = "${aws_alb.test.dns_name}"
    zone_id  = "${aws_alb.test.zone_id}"
    evaluate_target_health = true
  }
}
