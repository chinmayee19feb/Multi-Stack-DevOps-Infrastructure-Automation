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