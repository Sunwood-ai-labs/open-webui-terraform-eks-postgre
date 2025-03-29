/**
 * EKSノードグループの設定
 */

# EKSノードグループ
resource "aws_eks_node_group" "main" {
  cluster_name    = aws_eks_cluster.main.name
  node_group_name = "${var.prefix}-node-group"
  node_role_arn   = aws_iam_role.eks_node.arn
  subnet_ids      = var.private_subnet_ids
  instance_types  = var.node_instance_types
  disk_size       = var.node_disk_size

  scaling_config {
    desired_size = var.node_desired_size
    min_size     = var.node_min_size
    max_size     = var.node_max_size
  }

  update_config {
    max_unavailable = 1
  }

  depends_on = [
    aws_iam_role_policy_attachment.eks_worker_node_policy,
    aws_iam_role_policy_attachment.eks_cni_policy,
    aws_iam_role_policy_attachment.eks_container_registry
  ]

  tags = local.tags
}

# クラスターアクセス確保のための待機リソース
resource "null_resource" "wait_for_cluster" {
  depends_on = [
    aws_eks_cluster.main,
    aws_eks_node_group.main
  ]

  provisioner "local-exec" {
    command = <<EOT
      aws eks update-kubeconfig --name ${aws_eks_cluster.main.name} --region ${var.region}
      kubectl wait --for=condition=ready nodes --all --timeout=5m
    EOT
  }
}