##########################################
# AMI (Amazon Linux 2023 - latest in region)
##########################################
data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"] # Amazon Linux 2023 AMI name pattern # The pattern to match against AMI names # "al2023" = Amazon Linux 2023 # "ami-" = indicates it's an AMI # "*" = wildcard for any version or date
  }

  filter {
    name   = "architecture"
    values = ["x86_64"] # 64-bit architecture Specifies we want 64-bit x86 architecture AMIs
  }
}

##########################################
# EC2 A: Frontend + Bastion (Public Subnet)
##########################################
resource "aws_instance" "frontend" {             # Creates an EC2 instance resource named "frontend"
  ami                         = data.aws_ami.amazon_linux.id
  instance_type               = "t3.small"           # This instance will host web applications and serve as a jump/bastion host
  subnet_id                   = aws_subnet.public.id # References a public subnet resource that must be defined elsewhere,Public subnets have routes to an Internet Gateway for direct internet access
  key_name                    = var.key_pair_name    # SSH key for access
  vpc_security_group_ids      = [aws_security_group.frontend.id] # Attach the frontend security group we defined earlier named "frontend"
  associate_public_ip_address = true                             # Gets public IP automatically
  iam_instance_profile        = aws_iam_instance_profile.cloudwatch_agent.name # Attach IAM instance profile for CloudWatch Agent

  
  # This instance will be my bastion host and run vote/result apps

  tags = merge(local.tags, { Name = "EC2-Frontend-Chinmayee" })         # merge() function combines a local variable called "tags" with an additional Name tag
}

# Associate Elastic IP with frontend instance (static public IP)
resource "aws_eip_association" "frontend_assoc" {
  instance_id   = aws_instance.frontend.id # References the ID of the frontend EC2 instance we just created
  allocation_id = aws_eip.frontend.id     # References the allocation ID of the Elastic IP we created earlier
}

##########################################
# EC2: Dedicated Bastion Host (Public Subnet)
##########################################
resource "aws_instance" "bastion" {
  ami                         = data.aws_ami.amazon_linux.id
  instance_type               = "t3.small"
  subnet_id                   = aws_subnet.public.id
  key_name                    = var.key_pair_name
  vpc_security_group_ids      = [aws_security_group.bastion.id] # Attach the bastion security group i defined earlier named "bastion"
  associate_public_ip_address = true
  iam_instance_profile        = aws_iam_instance_profile.cloudwatch_agent.name # Attach IAM instance profile for CloudWatch Agent

  tags = merge(local.tags, { Name = "EC2-Bastion-Chinmayee" })
}

##########################################
# EC2 B: Backend (Redis + Worker) — Private Subnet
##########################################
resource "aws_instance" "backend" {          # Creates an EC2 instance resource named "backend"
  ami                         = data.aws_ami.amazon_linux.id     # This instance will run the Redis server and background worker processes
  instance_type               = "t3.small"
  subnet_id                   = aws_subnet.private_app.id  # Specifies which subnet to launch the instance in - private subnet for backend
  key_name                    = var.key_pair_name   # Specifies the name of the SSH key pair for secure instance access
  vpc_security_group_ids      = [aws_security_group.backend.id] # Attach the backend security group we defined earlier named "backend"
  associate_public_ip_address = false                           # No public IP - more secure
  iam_instance_profile        = aws_iam_instance_profile.cloudwatch_agent.name # Attach IAM instance profile for CloudWatch Agent
  tags = merge(local.tags, { Name = "EC2-Backend-Chinmayee" })
}

##########################################
# EC2 C: Database (PostgreSQL) — Private Subnet
##########################################
resource "aws_instance" "db" {             # Creates an EC2 instance resource named "db"
  ami                         = data.aws_ami.amazon_linux.id
  instance_type               = "t3.small"
  subnet_id                   = aws_subnet.private_db.id # Specifies which subnet to launch the instance in - private subnet for database
  key_name                    = var.key_pair_name
  vpc_security_group_ids      = [aws_security_group.db.id]  # Attach the database security group we defined earlier named "db"
  associate_public_ip_address = false # No public IP - more secure Explicitly disables automatic assignment of a public IPv4 address
  iam_instance_profile        = aws_iam_instance_profile.cloudwatch_agent.name # Attach IAM instance profile for CloudWatch Agent

  tags = merge(local.tags, { Name = "EC2-DB-Chinmayee" })
}

##########################################
# Security Group: Frontend (HTTP + SSH)
##########################################
resource "aws_security_group" "frontend" {
  name   = "SG-Frontend-Chinmayee"
  vpc_id = aws_vpc.main.id

  # HTTP for users - allow web traffic from anywhere
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # SSH access - currently open to all for simplicity (consider restricting in production)
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    security_groups = [aws_security_group.bastion.id] # Only bastion can SSH
  }

  # Add port 8080 for the VOTE service
  ingress {
    from_port   = 8080                    # The vote application listens on port 8080  (commonly used as an alternative HTTP port)
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]           # Allow access from anywhere
  }

  # Add port 8081 for the RESULT service
  ingress {
    from_port   = 8081                    # The result application listens on port 8081
    to_port     = 8081
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Outbound allowed - instances can connect to internet
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"                    # All protocols
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(local.tags, { Name = "SG-Frontend-Chinmayee" })
}

##########################################
# Security Group: Bastion Host
##########################################
resource "aws_security_group" "bastion" {
  name   = "SG-Bastion-Chinmayee"
  vpc_id = aws_vpc.main.id

  # SSH access - only from your IP (secure)
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # For now, allow from anywhere. We'll restrict later.
  }

  # Outbound allowed - bastion can connect to private instances
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(local.tags, { Name = "SG-Bastion-Chinmayee" })
}

##########################################
# Security Group: Backend (Redis + Worker)
##########################################
resource "aws_security_group" "backend" {             # Security Group for Backend  
  name   = "SG-Backend-Chinmayee"                     # Sets the name of the security group to "SG-Backend-Chinmayee" This name will appear in the AWS console
  vpc_id = aws_vpc.main.id                            # Associates the security group with the VPC created earlier,It references the ID of a VPC

  # Redis only from Frontend - vote app connects to Redis
  ingress {
    from_port       = 6379                            # Redis default port
    to_port         = 6379    
    protocol        = "tcp"
    security_groups = [aws_security_group.frontend.id] # Only frontend can access
  }

  # SSH only from Frontend (bastion) - secure SSH through bastion
  ingress {
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.bastion.id] # Only bastion can SSH
  }
  
  # Result app on port 8081
  ingress {
    from_port   = 8081                                # The result application listens on port 8081
    to_port     = 8081
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  egress {
    from_port   = 0                     # Allows all outbound traffic from the backend instances, 0 means all ports
    to_port     = 0                     # This means the instances can connect to any port on external services
    protocol    = "-1"                  # "-1" means all protocols (TCP, UDP, ICMP, etc.)
    cidr_blocks = ["0.0.0.0/0"]         # Allows outbound traffic to ANY IP address on the internet
  }

  tags = merge(local.tags, { Name = "SG-Backend-Chinmayee" }) # Applies tags to the security group for identification,  merge() function combines a local variable called "tags" with an additional Name tag
}

##########################################
# Security Group: Database (PostgreSQL)
##########################################
resource "aws_security_group" "db" {                    # Creates an AWS Security Group resource named "db"
  name   = "SG-DB-Chinmayee"                  # Sets the name of the security group to "SG-DB-Chinmayee" This name will appear in the AWS console
  vpc_id = aws_vpc.main.id

  # Postgres from Backend (Worker) and Frontend (Result app)
  ingress {
    from_port = 5432                         # PostgreSQL default port - PostgreSQL typically runs on port 5432
    to_port   = 5432
    protocol  = "tcp"
    security_groups = [
      aws_security_group.backend.id, # Worker connects to database
      aws_security_group.frontend.id # Result app connects to database
    ]
  }

  # SSH only from Frontend (bastion) # secure SSH through bastion
  ingress {
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.bastion.id] # Only badstion can SSH
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"] # Allow all outbound traffic
  }

  tags = merge(local.tags, { Name = "SG-DB-Chinmayee" })      # Applies tags to the security group for identification
}

##########################################
# Elastic IP for Frontend (stable public address)
##########################################
resource "aws_eip" "frontend" {                   # Creates an Elastic IP resource named "frontend"
  domain = "vpc"                                  # Specifies that the Elastic IP is for use in a VPC
  tags   = merge(local.tags, { Name = "EIP-Frontend-Chinmayee" })   # Applies tags to the Elastic IP for identification
}

##########################################
# Elastic IP for Bastion (stable public address)
##########################################
resource "aws_eip" "bastion" {
  domain = "vpc"
  tags   = merge(local.tags, { Name = "EIP-Bastion-Chinmayee" })
}

# Associate Elastic IP with bastion instance
resource "aws_eip_association" "bastion_assoc" {
  instance_id   = aws_instance.bastion.id
  allocation_id = aws_eip.bastion.id
}

##########################################
# Outputs - Useful information after deployment
##########################################
output "frontend_public_ip" {               # Output the public IP of the frontend/bastion instance
  description = "Elastic IP of the frontend/bastion"            
  value       = aws_eip.frontend.public_ip           
}

output "frontend_public_dns" {
  description = "Public DNS of the frontend/bastion"
  value       = aws_instance.frontend.public_dns
}

output "backend_private_ip" {
  description = "Private IP of EC2 B (Redis + Worker)"
  value       = aws_instance.backend.private_ip
}

output "db_private_ip" {
  description = "Private IP of EC2 C (PostgreSQL)"
  value       = aws_instance.db.private_ip
}