##########################################
# IAM Role for CloudWatch Agent
##########################################
resource "aws_iam_role" "cloudwatch_agent" {        # Create an IAM role for CloudWatch Agent
  name = "CloudWatchAgentRole-Chinmayee"

  assume_role_policy = jsonencode({                 # Define the trust relationship for the role
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"               # Allow EC2 instances to assume this role
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"         # EC2 service can assume this role
        }
      }
    ]
  })

  tags = merge(local.tags, { Name = "CloudWatchAgentRole-Chinmayee" })  # Apply tags to the role
}

##########################################
# Attach CloudWatch Policy to Role
##########################################
resource "aws_iam_role_policy_attachment" "cloudwatch_agent" {          # Attach the CloudWatchAgentServerPolicy to the IAM role
  role       = aws_iam_role.cloudwatch_agent.name                       # Reference the IAM role created above
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"    # Predefined AWS managed policy for CloudWatch Agent
}

##########################################
# IAM Instance Profile
##########################################
resource "aws_iam_instance_profile" "cloudwatch_agent" {      # Create an IAM instance profile for EC2 instances to use the CloudWatch Agent role
  name = "CloudWatchAgentProfile-Chinmayee"                     # Name of the instance profile
  role = aws_iam_role.cloudwatch_agent.name                     # Associate the IAM role created above
}