output "cluster_id" {
  value = aws_eks_cluster.nakodtech.id
}

output "node_group_id" {
  value = aws_eks_node_group.nakodtech.id
}

output "vpc_id" {
  value = aws_vpc.nakodtech_vpc.id
}

output "subnet_ids" {
  value = aws_subnet.nakodtech_subnet[*].id
}