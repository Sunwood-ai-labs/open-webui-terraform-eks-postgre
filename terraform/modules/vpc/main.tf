/**
 * VPCモジュール
 * Open WebUIとPostgreSQLのためのネットワークインフラを構築します
 */

# 他のモジュールからのローカル変数を統合
locals {
  resource_prefix = var.prefix
  vpc_tags = merge(
    var.tags,
    {
      Name = "${var.prefix}-vpc"
    }
  )
}
