############################
# Outputs
############################
output "cluster_id" {
  value = aws_eks_cluster.nakodtech.id
}

output "cluster_name" {
  value = aws_eks_cluster.nakodtech.name
}

output "cluster_endpoint" {
  value = aws_eks_cluster.nakodtech.endpoint
}

output "node_group_id" {
  value = aws_eks_node_group.nakodtech.id
}

output "node_group_name" {
  value = aws_eks_node_group.nakodtech.node_group_name
}

output "vpc_id" {
  value = aws_vpc.nakodtech_vpc.id
}

output "subnet_ids" {
  value = aws_subnet.nakodtech_subnet[*].id
}

output "ebs_csi_irsa_role_arn" {
  value = aws_iam_role.ebs_csi_irsa_role.arn
}
