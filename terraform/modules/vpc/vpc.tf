/**
 * VPC本体と関連するリソース
 */

# VPC本体
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags                 = local.vpc_tags
}

# インターネットゲートウェイ
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = merge(
    var.tags,
    {
      Name = "${var.prefix}-igw"
    }
  )
}

# Elastic IPアドレス（NATゲートウェイ用）
resource "aws_eip" "nat" {
  count  = length(var.availability_zones)
  domain = "vpc"

  tags = merge(
    var.tags,
    {
      Name = "${var.prefix}-nat-eip-${count.index + 1}"
    }
  )
}