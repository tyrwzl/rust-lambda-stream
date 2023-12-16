resource "aws_apigatewayv2_domain_name" "public_endpoint" {
  domain_name = var.domain

  domain_name_configuration {
    certificate_arn = var.acm_certificate_arn
    endpoint_type   = "REGIONAL"
    security_policy = "TLS_1_2"
  }
}

resource "aws_apigatewayv2_api_mapping" "public_endpoint" {
  api_id      = aws_apigatewayv2_api.api.id
  domain_name = aws_apigatewayv2_domain_name.public_endpoint.id
  stage       = aws_apigatewayv2_stage.prod.id
}

resource "aws_route53_record" "public_endpoint" {
  zone_id = var.zone_id

  name = aws_apigatewayv2_domain_name.public_endpoint.domain_name
  type = "A"

  alias {
    evaluate_target_health = true
    name                   = aws_apigatewayv2_domain_name.public_endpoint.domain_name_configuration[0].target_domain_name
    zone_id                = aws_apigatewayv2_domain_name.public_endpoint.domain_name_configuration[0].hosted_zone_id
  }
}
