output "repository_urls" {
  description = "Map of repository names to their URLs"
  value = {
    for name, repo in aws_ecr_repository.repositories : name => repo.repository_url
  }
}

output "repository_arns" {
  description = "Map of repository names to their ARNs"
  value = {
    for name, repo in aws_ecr_repository.repositories : name => repo.arn
  }
}

output "product_repository_url" {
  description = "Product service ECR repository URL"
  value       = aws_ecr_repository.repositories["product"].repository_url
}

output "user_repository_url" {
  description = "User service ECR repository URL"
  value       = aws_ecr_repository.repositories["user"].repository_url
}

output "stress_repository_url" {
  description = "Stress testing ECR repository URL"
  value       = aws_ecr_repository.repositories["stress"].repository_url
}

output "ecr_repositories" {
  description = "ECR repository information for all services"
  value = {
    for name, repo in aws_ecr_repository.repositories : name => {
      name           = repo.name
      repository_url = repo.repository_url
      arn           = repo.arn
      registry_id   = repo.registry_id
    }
  }
}
