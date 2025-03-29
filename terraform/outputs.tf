output "vpc_id" {
  description = "作成されたVPCのID"
  value       = module.vpc.vpc_id
}

output "public_subnet_ids" {
  description = "パブリックサブネットのIDリスト"
  value       = module.vpc.public_subnet_ids
}

output "private_subnet_ids" {
  description = "プライベートサブネットのIDリスト"
  value       = module.vpc.private_subnet_ids
}

output "eks_cluster_name" {
  description = "EKSクラスターの名前"
  value       = module.eks.cluster_name
}

output "eks_cluster_endpoint" {
  description = "EKSクラスターのエンドポイント"
  value       = module.eks.cluster_endpoint
}

output "kubeconfig_path" {
  description = "kubeconfigファイルのパス"
  value       = module.eks.kubeconfig_path
}

output "db_instance_endpoint" {
  description = "PostgreSQLインスタンスのエンドポイント"
  value       = module.rds.db_instance_endpoint
}

output "db_instance_name" {
  description = "PostgreSQLインスタンスのデータベース名"
  value       = module.rds.db_instance_name
}

output "db_connection_string" {
  description = "PostgreSQL接続文字列"
  value       = module.rds.db_connection_string
  sensitive   = true
}

output "region" {
  description = "使用しているAWSリージョン"
  value       = var.region
}
