variable "service_name" {
  description = "サービス名"
  type        = string
}

variable "lambda_invoke_arn" {
  description = "API Gateway に統合する Lambda の invoke arn"
  type        = string
}

variable "lambda_function_name" {
  description = "API Gateway に統合する Lambda の function name"
  type        = string
}

variable "domain" {
  description = "API GW のドメイン名"
  type        = string
}

variable "acm_certificate_arn" {
  description = "API Gateway に紐付ける ACM ARN"
  type        = string
}

variable "zone_id" {
  description = "Route 53 レコードを登録するゾーン ID"
  type        = string
}
