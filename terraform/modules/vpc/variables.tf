variable "vpc_cidr" {
  description = "VPCのCIDRブロック"
  type        = string
  default     = "10.0.0.0/16"
}

variable "availability_zones" {
  description = "使用するアベイラビリティゾーンのリスト"
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b", "us-east-1c"]
}

variable "prefix" {
  description = "リソース名のプレフィックス"
  type        = string
  default     = "open-webui"
}

variable "tags" {
  description = "すべてのリソースに適用するタグ"
  type        = map(string)
  default     = {
    Environment = "dev"
    Project     = "open-webui"
    ManagedBy   = "terraform"
  }
}
