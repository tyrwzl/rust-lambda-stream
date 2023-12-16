variable "aws_region" {
  description = "aws region"
  default     = "ap-northeast-1"
  type        = string
}

variable "service_name" {
  description = "サービス名"
  type        = string

  default = "rust-lambda-stream"
}

variable "domain" {
  description = "ドメイン"
  type        = string

  default = "rust-lambda-stream.example.com"
}

variable "repo_name" {
  description = "アプリケーションコードを管理するレポジトリの名前"
  type        = string

  default = "rust-lambda-stream"
}

variable "zone_id" {
  description = "Route 53 レコードを登録するゾーン ID"
  type        = string

  default = ""
}

variable "secret_arns" {
  description = "Lambda で利用する SecretsManager Secret の ARN"
  type        = list(string)
  default     = []
}

variable "environment_variables" {
  description = "Lambda に付与する環境変数"
  type        = map(string)
  default     = {}
}

variable "response_timeout" {
  description = "Lambda のレスポンスタイムアウト"
  type        = number

  default = 90
}

variable "memory_size" {
  description = "Lambda のメモリサイズ"
  type        = number

  default = 256
}
