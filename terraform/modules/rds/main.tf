/**
 * RDSモジュール
 * Open WebUI用のPostgreSQLデータベースを構築します
 */

resource "aws_db_subnet_group" "main" {
  name       = "${var.prefix}-db-subnet-group"
  subnet_ids = var.private_subnet_ids

  tags = merge(
    var.tags,
    {
      Name = "${var.prefix}-db-subnet-group"
    }
  )
}

resource "aws_db_parameter_group" "postgres" {
  name   = "${var.prefix}-postgres-params"
  family = "postgres17"

  parameter {
    name  = "log_connections"
    value = "1"
  }

  tags = merge(
    var.tags,
    {
      Name = "${var.prefix}-postgres-params"
    }
  )
}

resource "aws_db_instance" "postgres" {
  identifier             = "${var.prefix}-postgres"
  engine                 = "postgres"
  engine_version         = var.postgres_version
  instance_class         = var.db_instance_class
  allocated_storage      = var.allocated_storage
  max_allocated_storage  = var.max_allocated_storage
  storage_type           = "gp2"
  storage_encrypted      = true
  db_name                = var.db_name
  username               = var.db_username
  password               = var.db_password
  port                   = 5432
  publicly_accessible    = false
  vpc_security_group_ids = [var.rds_security_group_id]
  db_subnet_group_name   = aws_db_subnet_group.main.name
  parameter_group_name   = aws_db_parameter_group.postgres.name
  skip_final_snapshot    = var.skip_final_snapshot
  deletion_protection    = var.deletion_protection
  backup_retention_period = var.backup_retention_period
  backup_window          = var.backup_window
  maintenance_window     = var.maintenance_window
  multi_az               = var.multi_az
  apply_immediately      = var.apply_immediately

  tags = merge(
    var.tags,
    {
      Name = "${var.prefix}-postgres"
    }
  )
}
