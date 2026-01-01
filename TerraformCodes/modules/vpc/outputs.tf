output "vpc_id" {
  value = aws_vpc.main.id
}

output "public_subnet_01_id" {
  value = aws_subnet.public_subnet_01.id
}

output "public_subnet_02_id" {
  value = aws_subnet.public_subnet_02.id
}

output "private_subnet_01_id" {
  value = aws_subnet.private_subnet_01.id
}

output "private_subnet_02_id" {
  value = aws_subnet.private_subnet_02.id
}

output "public_route_table_id" {
  value = aws_route_table.public_rt.id
}

output "private_route_table1_id" {
  value = aws_route_table.private_rt1.id
}

output "private_route_table2_id" {
  value = aws_route_table.private_rt2.id
}

output "internet_gateway_id" {
  value = aws_internet_gateway.igw.id
}

output "nat_gateway1_id" {
  value = aws_nat_gateway.natgw1a.id
}

output "nat_gateway2_id" {
  value = aws_nat_gateway.natgw1b.id
}