# IAM Role for EC2 instances
resource "aws_iam_role" "ec2_ecr_access_role" {
  provider = aws.region1
  name     = "ec2-ecr-access-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Name    = "ec2-ecr-access-role"
    project = var.project_name
    region  = var.region1
  }
}

# IAM Policy for ECR access
resource "aws_iam_role_policy" "ecr_access_policy" {
  provider = aws.region1
  name     = "ecr-access-policy"
  role     = aws_iam_role.ec2_ecr_access_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ecr:GetAuthorizationToken",
          "ecr:BatchCheckLayerAvailability",
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage"
        ]
        Resource = "*"
      }
    ]
  })
}

# IAM Instance Profile
resource "aws_iam_instance_profile" "ec2_ecr_profile" {
  provider = aws.region1
  name     = "ec2-ecr-profile"
  role     = aws_iam_role.ec2_ecr_access_role.name
}
