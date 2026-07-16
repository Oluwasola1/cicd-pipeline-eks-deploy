terraform {
  required_version = ">= 1.6.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

variable "aws_region" {
  description = "AWS region — must match the EKS cluster from Project 1"
  type        = string
  default     = "eu-central-1"
}

variable "repository_name" {
  description = "Name of the ECR repository"
  type        = string
  default     = "cicd-demo"
}

resource "aws_ecr_repository" "app" {
  name                 = var.repository_name
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    Project   = "cicd-pipeline-eks-deploy"
    ManagedBy = "terraform"
  }
}

# Keep only the last 10 images so the repo doesn't grow unbounded as the
# pipeline runs on every push.
resource "aws_ecr_lifecycle_policy" "app" {
  repository = aws_ecr_repository.app.name

  policy = jsonencode({
    rules = [
      {
        rulePriority = 1
        description  = "Keep last 10 images"
        selection = {
          tagStatus   = "any"
          countType   = "imageCountMoreThan"
          countNumber = 10
        }
        action = {
          type = "expire"
        }
      }
    ]
  })
}

output "repository_url" {
  description = "Full URL of the ECR repository — used as the GitHub Actions secret ECR_REPOSITORY_URL"
  value       = aws_ecr_repository.app.repository_url
}
