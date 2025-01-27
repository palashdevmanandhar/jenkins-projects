resource "aws_ecr_repository" "react_image_repo" {
  provider             = aws.region1
  name                 = "${var.project_name}-repo"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  lifecycle {
    prevent_destroy = false
  }

  force_delete = true

  tags = {
    Name    = "${var.project_name}-repo"
    project = var.project_name
    region  = var.region1
  }
}

# ECR Lifecycle Policy
resource "aws_ecr_lifecycle_policy" "react_image_repo_lifecycle" {
  provider   = aws.region1
  repository = aws_ecr_repository.react_image_repo.name

  policy = jsonencode({
    rules = [{
      rulePriority = 1
      description  = "Keep last 30 images"
      selection = {
        tagStatus   = "any"
        countType   = "imageCountMoreThan"
        countNumber = 30
      }
      action = {
        type = "expire"
      }
    }]
  })
}



