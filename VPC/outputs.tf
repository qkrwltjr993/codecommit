output "vpc_WEB_id" {
  description = "The name of vpc WEB id"
  value = aws_vpc.vpc-WEB.id
}

output "vpc_name" {
  value = var.tag_name
}
