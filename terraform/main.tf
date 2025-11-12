##########################################
# AWS Provider
##########################################
provider "aws" {
  region = "eu-west-1"                     # Specifies the AWS region to deploy resources in
}

##########################################
# Terraform Configuration
##########################################
terraform {
  required_version = ">= 1.8.0"                    # Specifies the minimum required Terraform version
}

##########################################
# Local Values
##########################################
locals {
  vpc_cidr        = "10.20.0.0/16"             # CIDR block for the VPC
  public_a_cidr   = "10.20.1.0/24"         # CIDR block for the public subnet
  private_a_cidr  = "10.20.2.0/24"     # CIDR block for the private application subnet
  private_db_cidr = "10.20.3.0/24"    # CIDR block for the private database subnet

  # ADDED THESE 3 LINES FOR MULTI-AZ
  public_b_cidr      = "10.20.4.0/24"     # NEW: CIDR for public subnet in eu-west-1b
  private_app_b_cidr = "10.20.5.0/24"     # NEW: CIDR for private app subnet in eu-west-1b  
  private_db_b_cidr  = "10.20.6.0/24"     # NEW: CIDR for private db subnet in eu-west-1b

  tags = {
    Project   = "IRONHACK-PROJECT-1-Chinmayee"      # Tags to be applied to all resources for identification
    Env       = "dev"
    Owner     = "Chinmayee"                    
    ManagedBy = "Terraform"                     # Indicates that resources are managed by Terraform
  }
}

##########################################
# Application Load Balancer (NEW RESOURCE)
##########################################

# ALB Security Group
resource "aws_security_group" "alb" {
  name        = "SG-ALB-Chinmayee"
  description = "Security group for Application Load Balancer"
  vpc_id      = aws_vpc.main.id

  # HTTP from anywhere
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # HTTPS from anywhere 
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow all outbound
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(local.tags, { Name = "SG-ALB-Chinmayee" })
}

##########################################
# Application Load Balancer
##########################################

# ALB Resource
resource "aws_lb" "main" {
  name               = "ALB-Chinmayee"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb.id]
  subnets            = [aws_subnet.public.id, aws_subnet.public_b.id]  # Both AZs!

  enable_deletion_protection = false  # Set to true in production

  tags = merge(local.tags, { Name = "ALB-Chinmayee" })
}

##########################################
# Target Groups
##########################################

# Target Group for Vote App (port 8080)
resource "aws_lb_target_group" "vote" {
  name     = "TG-Vote-Chinmayee"
  port     = 8080
  protocol = "HTTP"
  vpc_id   = aws_vpc.main.id
  target_type = "instance"

  health_check {
    path                = "/"
    port                = "8080"
    protocol            = "HTTP"
    timeout             = 5
    interval            = 30
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }

  tags = merge(local.tags, { Name = "TG-Vote-Chinmayee" })
}

# Target Group for Result App (port 8081)  
resource "aws_lb_target_group" "result" {
  name     = "TG-Result-Chinmayee"
  port     = 8081
  protocol = "HTTP"
  vpc_id   = aws_vpc.main.id
  target_type = "instance"

  health_check {
    path                = "/"
    port                = "8081"
    protocol            = "HTTP"
    timeout             = 5
    interval            = 30
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }

  tags = merge(local.tags, { Name = "TG-Result-Chinmayee" })
}

##########################################
# ALB Listeners
##########################################

# HTTP Listener
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.main.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = "fixed-response"
    fixed_response {
      content_type = "text/plain"
      message_body = "No route matched"
      status_code  = "404"
    }
  }

  tags = merge(local.tags, { Name = "Listener-HTTP-Chinmayee" })
}

# Listener Rule for Vote App
resource "aws_lb_listener_rule" "vote" {
  listener_arn = aws_lb_listener.http.arn
  priority     = 100

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.vote.arn
  }

  condition {
    path_pattern {
      values = ["/vote*"]
    }
  }

  tags = merge(local.tags, { Name = "Rule-Vote-Chinmayee" })
}

# Listener Rule for Result App
resource "aws_lb_listener_rule" "result" {
  listener_arn = aws_lb_listener.http.arn
  priority     = 200

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.result.arn
  }

  condition {
    path_pattern {
      values = ["/result*"]
    }
  }

  tags = merge(local.tags, { Name = "Rule-Result-Chinmayee" })
}

##########################################
# Register Instances with Target Groups
##########################################

# Register frontend instance with Vote target group
resource "aws_lb_target_group_attachment" "vote" {
  target_group_arn = aws_lb_target_group.vote.arn
  target_id        = aws_instance.frontend.id
  port             = 8080
}

# Register frontend instance with Result target group  
resource "aws_lb_target_group_attachment" "result" {
  target_group_arn = aws_lb_target_group.result.arn
  target_id        = aws_instance.frontend.id
  port             = 8081
}