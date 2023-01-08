output "vpc_WEB_id" {
  description = "The name of vpc WEB id"
  value = aws_vpc.vpc-WEB.id
}

output "vpc_name" {
  value = var.tag_name
}

output "subnet" {
  description = "The name of vpc WEB id"
  value = aws_subnet.subnets
}

output "igw_id" {
  description = "The name of vpc-WEB id"
  value = aws_internet_gateway.WEB.id
}

output "route_public_id" {
    description = "get route_public_id"
    value = aws_route_table.public-table.id

}
