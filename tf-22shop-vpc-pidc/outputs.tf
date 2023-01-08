output "vpc_GeC_id" {
  description = "The name of vpc GeC id"
  value = aws_vpc.vpc-GeC.id
}

output "vpc_name" {
  value = var.tag_name
}

output "subnet" {
  description = "The name of vpc GeC id"
  value = aws_subnet.subnets
}

output "igw_id" {
  description = "The name of VPC-GeC id"
  value = aws_internet_gateway.GeC.id
}

output "route_public_id" {
    description = "get route_public_id"
    value = aws_route_table.public-table.id

}
