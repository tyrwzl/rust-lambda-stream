module "acm" {
  source  = "./modules/acm"
  domain  = var.domain
  zone_id = var.zone_id

  providers = {
    aws           = aws
    aws.us_east_1 = aws
  }
}

module "websocket" {
  source = "./modules/lambda"

  service_name          = "${var.service_name}-websocket"
  secret_arns           = var.secret_arns
  environment_variables = {
    OPENAI_API_KEY = "sk-"
OPENAI_ORG_ID	= "org-"
  }

  response_timeout = var.response_timeout
  memory_size      = var.memory_size
}

module "apigateway" {
  source = "./modules/apigateway/ws"

  service_name         = var.service_name
  lambda_invoke_arn    = module.lambda.lambda_invoke_arn
  lambda_function_name = module.lambda.lambda_function_name
  domain               = var.domain
  acm_certificate_arn  = module.acm.acm_arn
  zone_id              = var.zone_id
}

module "lambda_stream" {
  source = "./modules/lambda"

  service_name          = "${var.service_name}-lambda-stream"
  secret_arns           = var.secret_arns
  environment_variables = {
    OPENAI_API_KEY = "sk-"
OPENAI_ORG_ID	= "org-"
  }

  response_timeout = var.response_timeout
  memory_size      = var.memory_size
    enable_response_stream = true
}
