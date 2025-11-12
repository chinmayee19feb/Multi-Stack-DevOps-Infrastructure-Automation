##########################################
# Outputs
##########################################

# VPC ID
output "vpc_id" {       
  description = "The ID of the created VPC"
  value       = aws_vpc.main.id
}

# Public Subnet ID          
output "public_subnet_id" {       
  description = "Public subnet for frontend/bastion"
  value       = aws_subnet.public.id
}

# Private Subnet IDs
output "private_app_subnet_id" {
  description = "Private subnet for backend (Redis/Worker)"
  value       = aws_subnet.private_app.id
}

output "private_db_subnet_id" {
  description = "Private subnet for database (PostgreSQL)"
  value       = aws_subnet.private_db.id
}

# Internet Gateway
output "internet_gateway_id" {
  description = "Internet Gateway ID"
  value       = aws_internet_gateway.igw.id
}

# NAT Gateway Public IP
output "nat_public_ip" {
  description = "Public IP address of the NAT Gateway"
  value       = aws_eip.nat.public_ip
}

### Private DNS Names ###
output "backend_private_dns" {
  description = "Private DNS name of the backend instance"
  value       = aws_instance.backend.private_dns
}

output "db_private_dns" {
  description = "Private DNS name of the database instance"
  value       = aws_instance.db.private_dns
}

output "frontend_private_dns" {
  description = "Private DNS name of the frontend instance"
  value       = aws_instance.frontend.private_dns
}

output "bastion_public_ip" {
  description = "Elastic IP of the bastion host"
  value       = aws_eip.bastion.public_ip
}

output "bastion_public_dns" {
  description = "Public DNS of the bastion host"
  value       = aws_eip.bastion.public_dns
}

# Multi-AZ Subnet IDs
output "public_b_subnet_id" {
  description = "Public subnet in eu-west-1b for ALB"
  value       = aws_subnet.public_b.id
}

output "private_app_b_subnet_id" {
  description = "Private app subnet in eu-west-1b"
  value       = aws_subnet.private_app_b.id
}

output "private_db_b_subnet_id" {
  description = "Private database subnet in eu-west-1b"
  value       = aws_subnet.private_db_b.id
}

## ALB Output ALB DNS Name
output "alb_dns_name" {
  description = "DNS name of the Application Load Balancer"
  value       = aws_lb.main.dns_name
}
# New Instance Private IPs
output "frontend_b_private_ip" {
  description = "Private IP of Frontend instance in eu-west-1b"
  value       = aws_instance.frontend_b.private_ip
}

output "backend_b_private_ip" {
  description = "Private IP of Backend instance in eu-west-1b"
  value       = aws_instance.backend_b.private_ip
}

output "db_b_private_ip" {
  description = "Private IP of Database instance in eu-west-1b"
  value       = aws_instance.db_b.private_ip
}

# New Instance Private DNS
output "frontend_b_private_dns" {
  description = "Private DNS of Frontend instance in eu-west-1b"
  value       = aws_instance.frontend_b.private_dns
}

output "backend_b_private_dns" {
  description = "Private DNS of Backend instance in eu-west-1b"
  value       = aws_instance.backend_b.private_dns
}

output "db_b_private_dns" {
  description = "Private DNS of Database instance in eu-west-1b"
  value       = aws_instance.db_b.private_dns
}