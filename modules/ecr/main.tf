resource "aws_ecr_repository" "repositories" {
  for_each = toset(var.repositories)
  
  name                 = "${var.prefix}-${each.value}"
  image_tag_mutability = var.image_tag_mutability

  image_scanning_configuration {
    scan_on_push = var.scan_on_push
  }

  encryption_configuration {
    encryption_type = "AES256"
  }

  tags = merge(var.common_tags, {
    Name        = "${var.prefix}-${each.value}"
    Repository  = each.value
    Service     = title(each.value)
  })
}

resource "aws_ecr_lifecycle_policy" "repositories" {
  for_each = aws_ecr_repository.repositories

  repository = each.value.name

  policy = jsonencode({
    rules = [
      {
        rulePriority = 1
        description  = "Keep last 30 images"
        selection = {
          tagStatus     = "tagged"
          tagPrefixList = ["v"]
          countType     = "imageCountMoreThan"
          countNumber   = 30
        }
        action = {
          type = "expire"
        }
      },
      {
        rulePriority = 2
        description  = "Delete untagged images older than 1 day"
        selection = {
          tagStatus   = "untagged"
          countType   = "sinceImagePushed"
          countUnit   = "days"
          countNumber = 1
        }
        action = {
          type = "expire"
        }
      }
    ]
  })
}

resource "null_resource" "build_and_push_images" {
  depends_on = [aws_ecr_repository.repositories]

  triggers = {
    repository_urls_json = jsonencode({ for name, repo in aws_ecr_repository.repositories : name => repo.repository_url })
    prefix               = var.prefix
    region               = data.aws_region.current.name
  }

  provisioner "local-exec" {
    interpreter = ["/bin/bash", "-c"]
    command     = <<EOT
set -euo pipefail
REGION="${data.aws_region.current.name}"
ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
aws ecr get-login-password --region "$REGION" | docker login --username AWS --password-stdin "$ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com"
for app in product user stress; do
  cd "${path.root}/app-files/$app"
  docker build --platform linux/amd64 -t "${var.prefix}-$app:latest" .
  docker tag "${var.prefix}-$app:latest" "$ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com/${var.prefix}-$app:v1"
  docker push "$ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com/${var.prefix}-$app:v1"
  cd - >/dev/null
done
EOT
  }
}

data "aws_region" "current" {}
