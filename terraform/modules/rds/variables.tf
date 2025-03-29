variable "prefix" {
  description = "リソース名のプレフィックス"
  type        = string
  default     = "open-webui"
}

variable "private_subnet_ids" {
  description = "RDSを配置するプライベートサブネットのIDリスト"
  type        = list(string)
}

variable "rds_security_group_id" {
  description = "RDS用セキュリティグループのID"
  type        = string
}

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

variable "skip_final_snapshot" {
  description = "インスタンス削除時に最終スナップショットを作成しないかどうか"
  type        = bool
  default     = true
}

variable "deletion_protection" {
  description = "削除保護を有効にするかどうか"
  type        = bool
  default     = false
}

variable "backup_retention_period" {
  description = "バックアップの保持期間（日数）"
  type        = number
  default     = 7
}

variable "backup_window" {
  description = "バックアップウィンドウ"
  type        = string
  default     = "03:00-04:00"
}

variable "maintenance_window" {
  description = "メンテナンスウィンドウ"
  type        = string
  default     = "Mon:04:00-Mon:05:00"
}

variable "multi_az" {
  description = "マルチAZ配置を有効にするかどうか"
  type        = bool
  default     = false
}

variable "apply_immediately" {
  description = "変更を即時適用するかどうか"
  type        = bool
  default     = true
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
