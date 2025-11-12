##########################################
# VPC
##########################################
resource "aws_vpc" "main" {               # Creates a VPC resource named "main"
  cidr_block           = local.vpc_cidr   # Uses the CIDR block defined in local variables
  enable_dns_support   = true             # Enables DNS support in the VPC
  enable_dns_hostnames = true             # Enables DNS hostnames in the VPC

  tags = merge(local.tags, { Name = "VPC-Chinmayee" })   # Applies tags to the VPC for identification
}

##########################################
# Internet Gateway
##########################################
resource "aws_internet_gateway" "igw" {      # Creates an Internet Gateway resource named "igw"
  vpc_id = aws_vpc.main.id                   # Attaches the Internet Gateway to the VPC created earlier

  tags = merge(local.tags, { Name = "IGW-Chinmayee" })    # Applies tags to the Internet Gateway for identification
}

##########################################
# Subnets (Single AZ)
##########################################
resource "aws_subnet" "public" {              # Creates a public subnet resource named "public"
  vpc_id                  = aws_vpc.main.id     # Associates the subnet with the main VPC
  cidr_block              = local.public_a_cidr # Uses the CIDR block defined in local variables
  availability_zone       = "eu-west-1a"  # Specifies the availability zone for the subnet
  map_public_ip_on_launch = true         # Automatically assigns public IPs to instances launched in this subnet

  tags = merge(local.tags, { Name = "Subnet-Public-Chinmayee" })  # Applies tags to the subnet for identification
}

resource "aws_subnet" "private_app" {          # Creates a private subnet resource named "private_app"
  vpc_id            = aws_vpc.main.id             # Associates the subnet with the main VPC 
  cidr_block        = local.private_a_cidr   # Uses the CIDR block defined in local variables
  availability_zone = "eu-west-1a"          # Specifies the availability zone for the subnet

  tags = merge(local.tags, { Name = "Subnet-Private-App-Chinmayee" })
}

resource "aws_subnet" "private_db" {         # Creates a private subnet resource named "private_db"
  vpc_id            = aws_vpc.main.id            # Associates the subnet with the main VPC
  cidr_block        = local.private_db_cidr   # Uses the CIDR block defined in local variables
  availability_zone = "eu-west-1a"       # Specifies the availability zone for the subnet

  tags = merge(local.tags, { Name = "Subnet-Private-DB-Chinmayee" })  
}

##########################################
# Route Table (Public)
##########################################
resource "aws_route_table" "public" {             # Creates a route table resource named "public"
  vpc_id = aws_vpc.main.id                # Associates the route table with the main VPC

  route {
    cidr_block = "0.0.0.0/0"              # Route for all IPv4 traffic
    gateway_id = aws_internet_gateway.igw.id    # Routes traffic to the Internet Gateway
  }

  tags = merge(local.tags, { Name = "RT-Public-Chinmayee" })      # Applies tags to the route table for identification
}

resource "aws_route_table_association" "public_assoc" {  # Associates the public route table with the public subnet
  subnet_id      = aws_subnet.public.id         # References the public subnet created earlier
  route_table_id = aws_route_table.public.id   # References the public route table created earlier  
}

##########################################
# NAT Gateway (in Public Subnet)
##########################################
resource "aws_eip" "nat" {                     # Creates an Elastic IP resource for the NAT Gateway
  domain = "vpc"                               # Specifies that the Elastic IP is for use in a VPC

  tags = merge(local.tags, { Name = "EIP-NAT-Chinmayee" })  # Applies tags to the Elastic IP for identification
}

resource "aws_nat_gateway" "nat" {      # Creates a NAT Gateway resource named "nat"
  subnet_id     = aws_subnet.public.id  # Places the NAT Gateway in the public subnet
  allocation_id = aws_eip.nat.id        # Associates the Elastic IP created earlier with the NAT Gateway  

  tags = merge(local.tags, { Name = "NATGW-Chinmayee" })
}

##########################################
# Route Table (Private)
##########################################
resource "aws_route_table" "private" {            # Creates a route table resource named "private"
  vpc_id = aws_vpc.main.id                        # Associates the route table with the main VPC

  route {                                         # Route for all IPv4 traffic
    cidr_block     = "0.0.0.0/0"                  # Route for all IPv4 traffic
    nat_gateway_id = aws_nat_gateway.nat.id       # Routes traffic to the NAT Gateway
  }

  tags = merge(local.tags, { Name = "RT-Private-Chinmayee" })
}

resource "aws_route_table_association" "private_app_assoc" {  # Associates the private route table with the private application subnet
  subnet_id      = aws_subnet.private_app.id                  # References the private application subnet
  route_table_id = aws_route_table.private.id                 # References the private route table created earlier
}

resource "aws_route_table_association" "private_db_assoc" {   # Associates the private route table with the private database subnet
  subnet_id      = aws_subnet.private_db.id                 # References the private database subnet        
  route_table_id = aws_route_table.private.id              # References the private route table created earlier
}

##########################################
# Additional Subnets for Multi-AZ Deployment
##########################################

# Additional Public Subnet for ALB in eu-west-1b
resource "aws_subnet" "public_b" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.20.4.0/24"  # New CIDR for eu-west-1b
  availability_zone       = "eu-west-1b"
  map_public_ip_on_launch = true

  tags = merge(local.tags, { Name = "Subnet-Public-1b-Chinmayee" })
}

# Additional Private App Subnet for eu-west-1b
resource "aws_subnet" "private_app_b" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.20.5.0/24"  # New CIDR for eu-west-1b
  availability_zone = "eu-west-1b"

  tags = merge(local.tags, { Name = "Subnet-Private-App-1b-Chinmayee" })
}

# Additional Private DB Subnet for eu-west-1b
resource "aws_subnet" "private_db_b" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.20.6.0/24"  # New CIDR for eu-west-1b
  availability_zone = "eu-west-1b"

  tags = merge(local.tags, { Name = "Subnet-Private-DB-1b-Chinmayee" })
}

##########################################
# Additional Route Table Associations for new subnets
##########################################

resource "aws_route_table_association" "public_b_assoc" {
  subnet_id      = aws_subnet.public_b.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "private_app_b_assoc" {
  subnet_id      = aws_subnet.private_app_b.id
  route_table_id = aws_route_table.private.id
}

resource "aws_route_table_association" "private_db_b_assoc" {
  subnet_id      = aws_subnet.private_db_b.id
  route_table_id = aws_route_table.private.id
}
