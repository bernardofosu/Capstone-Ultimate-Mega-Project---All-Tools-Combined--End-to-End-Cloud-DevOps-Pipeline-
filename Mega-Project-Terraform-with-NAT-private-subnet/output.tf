############################
# Outputs
############################

# Output: EKS cluster ID
output "cluster_id" {
  value = aws_eks_cluster.nakodtech.id
}

# Output: EKS cluster name
output "cluster_name" {
  value = aws_eks_cluster.nakodtech.name
}

# Output: EKS cluster API endpoint
output "cluster_endpoint" {
  value = aws_eks_cluster.nakodtech.endpoint
}

# Output: EKS node group ID (primary node group)
output "node_group_id" {
  value = aws_eks_node_group.nakodtech.id
}

# Output: EKS node group name
output "node_group_name" {
  value = aws_eks_node_group.nakodtech.node_group_name
}

# Output: VPC ID
output "vpc_id" {
  value = aws_vpc.nakodtech_vpc.id
}

# Output: Public subnet IDs (original public subnets)
output "public_subnet_ids" {
  value = aws_subnet.nakodtech_subnet[*].id
}

# Output: Private subnet IDs (new private subnets)
output "private_subnet_ids" {
  value = aws_subnet.nakodtech_private_subnet[*].id
}

# Output: EBS CSI IRSA role ARN
output "ebs_csi_irsa_role_arn" {
  value = aws_iam_role.ebs_csi_irsa_role.arn
}

# Output: NAT Gateway IDs (one per AZ)
output "nat_gateway_ids" {
  value = aws_nat_gateway.nakodtech_nat[*].id
}

# Output: NAT EIP allocation IDs (one per NAT)
output "nat_eip_allocation_ids" {
  value = aws_eip.nat_eip[*].id
}

# Output: Private route table IDs (one per AZ)
output "private_route_table_ids" {
  value = aws_route_table.nakodtech_private_route_table[*].id
}
