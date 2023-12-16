
output "acm_arn" {
  value       = aws_acm_certificate.main.arn
  description = "ドメインに対して発行された ACM ARN"
}
