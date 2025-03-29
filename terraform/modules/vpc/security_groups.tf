/**
 * セキュリティグループ
 * EKSとRDSのセキュリティグループ定義
 */

# セキュリティグループ（EKS用）
resource "aws_security_group" "eks" {
  name        = "${var.prefix}-eks-sg"
  description = "Security group for EKS cluster"
  vpc_id      = aws_vpc.main.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(
    var.tags,
    {
      Name = "${var.prefix}-eks-sg"
    }
  )
}

# セキュリティグループ（RDS用）
resource "aws_security_group" "rds" {
  name        = "${var.prefix}-rds-sg"
  description = "Security group for RDS PostgreSQL"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.eks.id]
  }
  
  # 開発マシンからのアクセスを許可
  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["27.127.55.40/32"]
    description = "Local development machine access"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(
    var.tags,
    {
      Name = "${var.prefix}-rds-sg"
    }
  )
}