/**
 * サブネット定義
 * パブリックとプライベートのサブネットを複数のAZに展開
 */

# パブリックサブネット
resource "aws_subnet" "public" {
  count                   = length(var.availability_zones)
  vpc_id                  = aws_vpc.main.id
  cidr_block              = cidrsubnet(var.vpc_cidr, 8, count.index)
  availability_zone       = var.availability_zones[count.index]
  map_public_ip_on_launch = true

  tags = merge(
    var.tags,
    {
      Name                                          = "${var.prefix}-public-subnet-${count.index + 1}"
      "kubernetes.io/cluster/${var.prefix}-cluster" = "shared"
      "kubernetes.io/role/elb"                      = "1"
    }
  )
}

# プライベートサブネット
resource "aws_subnet" "private" {
  count                   = length(var.availability_zones)
  vpc_id                  = aws_vpc.main.id
  cidr_block              = cidrsubnet(var.vpc_cidr, 8, count.index + length(var.availability_zones))
  availability_zone       = var.availability_zones[count.index]
  map_public_ip_on_launch = false

  tags = merge(
    var.tags,
    {
      Name                                          = "${var.prefix}-private-subnet-${count.index + 1}"
      "kubernetes.io/cluster/${var.prefix}-cluster" = "shared"
      "kubernetes.io/role/internal-elb"             = "1"
    }
  )
}

# NATゲートウェイ
resource "aws_nat_gateway" "main" {
  count         = length(var.availability_zones)
  allocation_id = aws_eip.nat[count.index].id
  subnet_id     = aws_subnet.public[count.index].id

  tags = merge(
    var.tags,
    {
      Name = "${var.prefix}-nat-gw-${count.index + 1}"
    }
  )

  depends_on = [aws_internet_gateway.main]
}