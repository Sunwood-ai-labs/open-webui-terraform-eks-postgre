variable "prefix" {
  description = "リソース名のプレフィックス"
  type        = string
  default     = "open-webui"
}

variable "region" {
  description = "AWSリージョン"
  type        = string
  default     = "us-east-1"
}

variable "kubernetes_version" {
  description = "Kubernetesのバージョン"
  type        = string
  default     = "1.27"
}

variable "public_subnet_ids" {
  description = "パブリックサブネットのIDリスト"
  type        = list(string)
}

variable "private_subnet_ids" {
  description = "プライベートサブネットのIDリスト"
  type        = list(string)
}

variable "eks_security_group_id" {
  description = "EKS用セキュリティグループのID"
  type        = string
}

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

variable "aws_load_balancer_controller_version" {
  description = "AWS Load Balancer Controllerのバージョン"
  type        = string
  default     = "1.5.3"
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
