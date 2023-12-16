variable "domain" {
  description = "Route 53 で管理するドメイン"
  type        = string
}

variable "zone_id" {
  description = "Route 53 レコードを登録するゾーン ID"
  type        = string
}
