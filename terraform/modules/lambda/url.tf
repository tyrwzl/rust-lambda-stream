resource "aws_lambda_function_url" "main" {

  count = var.enable_response_stream ? 1 : 0

  function_name      = aws_lambda_function.main.function_name
  authorization_type = "NONE"
  cors {
    allow_methods = ["POST"]
    allow_origins = ["http://localhost:5173"]
    allow_headers = ["content-type"]
  }

  invoke_mode = "RESPONSE_STREAM"
}
