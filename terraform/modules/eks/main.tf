/**
 * EKSモジュール
 * Open WebUIを実行するためのKubernetesクラスターを構築します
 */

# 他のファイルで共有するローカル変数
locals {
  cluster_name = "${var.prefix}-cluster"
  tags = var.tags
}

# 現在のAWSアカウントID取得
data "aws_caller_identity" "current" {}
