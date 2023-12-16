resource "aws_lambda_function" "main" {
  function_name = var.service_name
  role          = aws_iam_role.lambda.arn

  package_type = "Image"
  image_uri    = "${aws_ecr_repository.main.repository_url}:latest"

  dynamic "environment" {
    for_each = length(keys(var.environment_variables)) == 0 ? [] : [true]
    content {
      variables = var.environment_variables
    }
  }

  timeout     = var.response_timeout
  memory_size = var.memory_size

  # update はアプリケーションソースコードの方で実施する
  lifecycle {
    ignore_changes = [
      image_uri
    ]
  }

  depends_on = [null_resource.image]
}
