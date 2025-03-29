variable "region" {
  description = "AWSリージョン"
  type        = string
  default     = "us-east-1"
}

variable "prefix" {
  description = "リソース名のプレフィックス"
  type        = string
  default     = "open-webui"
}

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

# Terraformバックエンド設定
variable "terraform_backend" {
  description = "Terraformのバックエンド設定"
  type = object({
    bucket         = string
    key            = string
    dynamodb_table = string
  })
  sensitive = true
}

variable "kubernetes_version" {
  description = "Kubernetesのバージョン"
  type        = string
  default     = "1.27"
}

# RDS関連の変数
variable "postgres_version" {
  description = "PostgreSQLのバージョン"
  type        = string
  default     = "14.6"
}

variable "db_instance_class" {
  description = "RDSインスタンスのクラス"
  type        = string
  default     = "db.t3.micro"
}

variable "allocated_storage" {
  description = "割り当てるストレージ容量（GB）"
  type        = number
  default     = 20
}

variable "max_allocated_storage" {
  description = "自動スケーリングの最大ストレージ容量（GB）"
  type        = number
  default     = 100
}

variable "db_name" {
  description = "データベース名"
  type        = string
  default     = "openwebuidb"
}

variable "db_username" {
  description = "データベースのマスターユーザー名"
  type        = string
  default     = "openwebui"
}

variable "db_password" {
  description = "データベースのマスターパスワード"
  type        = string
  sensitive   = true
}

variable "multi_az" {
  description = "マルチAZ配置を有効にするかどうか"
  type        = bool
  default     = false
}

# EKS関連の変数
variable "node_instance_types" {
  description = "EKSノードのインスタンスタイプ"
  type        = list(string)
  default     = ["t3.medium"]
}

variable "node_disk_size" {
  description = "EKSノードのディスクサイズ（GB）"
  type        = number
  default     = 20
}

variable "node_desired_size" {
  description = "EKSノードグループの希望するノード数"
  type        = number
  default     = 2
}

variable "node_min_size" {
  description = "EKSノードグループの最小ノード数"
  type        = number
  default     = 1
}

variable "node_max_size" {
  description = "EKSノードグループの最大ノード数"
  type        = number
  default     = 3
}

variable "default_tags" {
  description = "すべてのリソースに適用するデフォルトタグ"
  type        = map(string)
  default     = {
    Environment = "dev"
    Project     = "open-webui"
    ManagedBy   = "terraform"
  }
}
