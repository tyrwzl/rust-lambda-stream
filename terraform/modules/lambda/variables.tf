variable "service_name" {
  description = "サービス名"
  type        = string
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
  default     = 3
}

variable "memory_size" {
  description = "Lambda のメモリサイズ"
  type        = number
  default     = 128
}

variable "enable_response_stream" {
  type = bool
  default = false
}
