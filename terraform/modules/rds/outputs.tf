output "db_instance_address" {
  description = "PostgreSQLインスタンスのアドレス"
  value       = aws_db_instance.postgres.address
}

output "db_instance_endpoint" {
  description = "PostgreSQLインスタンスのエンドポイント"
  value       = aws_db_instance.postgres.endpoint
}

output "db_instance_name" {
  description = "PostgreSQLインスタンスのデータベース名"
  value       = aws_db_instance.postgres.db_name
}

output "db_instance_username" {
  description = "PostgreSQLインスタンスのマスターユーザー名"
  value       = aws_db_instance.postgres.username
}

output "db_instance_port" {
  description = "PostgreSQLインスタンスのポート"
  value       = aws_db_instance.postgres.port
}

output "db_connection_string" {
  description = "PostgreSQL接続文字列"
  value       = "postgresql://${aws_db_instance.postgres.username}:${var.db_password}@${aws_db_instance.postgres.endpoint}/${aws_db_instance.postgres.db_name}"
  sensitive   = true
}
