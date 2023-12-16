resource "aws_ecr_repository" "main" {
  name                 = var.service_name
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}

resource "aws_ecr_lifecycle_policy" "image_retention_policy" {
  repository = aws_ecr_repository.main.name

  policy = <<EOF
{
    "rules": [
        {
            "rulePriority": 1,
            "description": "Keep last 10 images",
            "selection": {
                "tagStatus": "any",
                "countType": "imageCountMoreThan",
                "countNumber": 10
            },
            "action": {
                "type": "expire"
            }
        }
    ]
}
EOF
}

resource "null_resource" "image" {
  provisioner "local-exec" {
    command = "aws ecr get-login-password | docker login --username AWS --password-stdin ${data.aws_caller_identity.current.account_id}.dkr.ecr.${data.aws_region.current.name}.amazonaws.com"
  }

  # ダミーイメージとしてalpineを利用する
  provisioner "local-exec" {
    command = "docker pull alpine:latest"
  }

  provisioner "local-exec" {
    command = "docker tag alpine:latest ${aws_ecr_repository.main.repository_url}"
  }

  provisioner "local-exec" {
    command = "docker push ${aws_ecr_repository.main.repository_url}"
  }
}
