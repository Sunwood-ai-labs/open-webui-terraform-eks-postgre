/**
 * Kubernetes認証関連の設定
 */

# aws-auth ConfigMap
resource "kubernetes_config_map_v1_data" "aws_auth" {
  metadata {
    name      = "aws-auth"
    namespace = "kube-system"
  }

  force = true

  data = {
    mapRoles = <<YAML
- rolearn: ${aws_iam_role.eks_node.arn}
  username: system:node:{{EC2PrivateDNSName}}
  groups:
    - system:bootstrappers
    - system:nodes
YAML
  }

  depends_on = [
    aws_eks_node_group.main,
    null_resource.wait_for_cluster
  ]
}