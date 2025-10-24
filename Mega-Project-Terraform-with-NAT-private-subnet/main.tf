terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0"
    }
  }
  required_version = ">= 1.0"
}

provider "aws" {
  region = "us-east-1"
}

############################
# Networking
############################

# ------------------------------
# VPC: main VPC for the cluster
# ------------------------------
# Creates a /16 VPC for the nakodtech environment
resource "aws_vpc" "nakodtech_vpc" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "nakodtech-vpc"
  }
}

# ------------------------------
# Public Subnets (2)
# ------------------------------
# Two public subnets (one per AZ) that map public IPs on launch
resource "aws_subnet" "nakodtech_subnet" {
  count                   = 2
  vpc_id                  = aws_vpc.nakodtech_vpc.id
  cidr_block              = cidrsubnet(aws_vpc.nakodtech_vpc.cidr_block, 8, count.index)
  availability_zone       = element(["us-east-1a", "us-east-1b"], count.index)
  map_public_ip_on_launch = true

  tags = {
    Name                                      = "nakodtech-subnet-${count.index}"
    "kubernetes.io/cluster/nakodtech-cluster" = "shared"
    "kubernetes.io/role/elb"                  = "1"
  }
}

# ------------------------------
# Private Subnets (2) - NEW
# ------------------------------
# Two private subnets (one per AZ) for worker instances and internal resources.
# These do NOT map public IPs and will route internet via the NAT Gateways.
resource "aws_subnet" "nakodtech_private_subnet" {
  count                   = 2
  vpc_id                  = aws_vpc.nakodtech_vpc.id
  # carve different /24s from the VPC so they don't overlap the public subnets
  cidr_block              = cidrsubnet(aws_vpc.nakodtech_vpc.cidr_block, 8, count.index + 2)
  availability_zone       = element(["us-east-1a", "us-east-1b"], count.index)
  map_public_ip_on_launch = false

  tags = {
    Name                                      = "nakodtech-private-subnet-${count.index}"
    "kubernetes.io/cluster/nakodtech-cluster" = "shared"
    "kubernetes.io/role/internal-elb"         = "1"
  }
}

# ------------------------------
# Internet Gateway
# ------------------------------
# IGW to provide internet access to public subnets
resource "aws_internet_gateway" "nakodtech_igw" {
  vpc_id = aws_vpc.nakodtech_vpc.id

  tags = {
    Name = "nakodtech-igw"
  }
}

# ------------------------------
# Public Route Table
# ------------------------------
# Route table for public subnets sending 0.0.0.0/0 -> IGW
resource "aws_route_table" "nakodtech_route_table" {
  vpc_id = aws_vpc.nakodtech_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.nakodtech_igw.id
  }

  tags = {
    Name = "nakodtech-route-table"
  }
}

# ------------------------------
# Public Route Table Associations
# ------------------------------
# Associates the public route table with each public subnet
resource "aws_route_table_association" "nakodtech_association" {
  count          = 2
  subnet_id      = aws_subnet.nakodtech_subnet[count.index].id
  route_table_id = aws_route_table.nakodtech_route_table.id
}

############################
# Security Groups
############################

# ------------------------------
# Security Group: cluster SG
# ------------------------------
# Security group for the EKS cluster control plane
resource "aws_security_group" "nakodtech_cluster_sg" {
  name   = "nakodtech-cluster-sg"
  vpc_id = aws_vpc.nakodtech_vpc.id

  ingress {
    description     = "EKS API from nodes"
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    security_groups = [aws_security_group.nakodtech_node_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "nakodtech-cluster-sg"
  }
}

# ------------------------------
# Security Group: node SG
# ------------------------------
# Security group for EKS nodes (broad open ingress/egress in this example)
resource "aws_security_group" "nakodtech_node_sg" {
  name   = "nakodtech-node-sg"
  vpc_id = aws_vpc.nakodtech_vpc.id

  ingress {
    description = "Allow SSH from anywhere (for demo only)"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "nakodtech-node-sg"
  }
}

############################
# IAM Roles
############################

# ------------------------------
# IAM Role: EKS Cluster Role
# ------------------------------
# IAM role assumed by the EKS control plane
resource "aws_iam_role" "nakodtech_cluster_role" {
  name = "nakodtech-cluster-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = { Service = "eks.amazonaws.com" },
        Action   = "sts:AssumeRole"
      }
    ]
  })
}

# ------------------------------
# IAM Role Attachment: Cluster Policy
# ------------------------------
# Attach AmazonEKSClusterPolicy to the cluster role
resource "aws_iam_role_policy_attachment" "nakodtech_cluster_role_policy" {
  role       = aws_iam_role.nakodtech_cluster_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

# ------------------------------
# IAM Role: Node Group Role
# ------------------------------
# IAM role for EC2 instances in the node group
resource "aws_iam_role" "nakodtech_node_group_role" {
  name = "nakodtech-node-group-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = { Service = "ec2.amazonaws.com" },
        Action   = "sts:AssumeRole"
      }
    ]
  })
}

# ------------------------------
# IAM Role Attachment: Worker Node Policy
# ------------------------------
# Attach the standard worker node policy
resource "aws_iam_role_policy_attachment" "nakodtech_node_group_role_policy" {
  role       = aws_iam_role.nakodtech_node_group_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}

# ------------------------------
# IAM Role Attachment: CNI Policy
# ------------------------------
# Attach the EKS CNI policy so nodes can manage ENIs
resource "aws_iam_role_policy_attachment" "nakodtech_node_group_cni_policy" {
  role       = aws_iam_role.nakodtech_node_group_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
}

# ------------------------------
# IAM Role Attachment: ECR ReadOnly
# ------------------------------
# Allow nodes to pull images from ECR
resource "aws_iam_role_policy_attachment" "nakodtech_node_group_registry_policy" {
  role       = aws_iam_role.nakodtech_node_group_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

############################
# EKS Cluster
############################

# ------------------------------
# EKS Cluster
# ------------------------------
# Creates the EKS control plane (uses cluster role defined above)
resource "aws_eks_cluster" "nakodtech" {
  name     = "nakodtech-cluster"
  role_arn = aws_iam_role.nakodtech_cluster_role.arn

  vpc_config {
    subnet_ids         = aws_subnet.nakodtech_subnet[*].id
    security_group_ids = [aws_security_group.nakodtech_cluster_sg.id]
  }

  depends_on = [
    aws_iam_role_policy_attachment.nakodtech_cluster_role_policy
  ]
}

############################
# Node Group
############################

# ------------------------------
# EKS Node Group
# ------------------------------
# Node group (EC2) for worker nodes. NOTE: still references your original public subnets.
resource "aws_eks_node_group" "nakodtech" {
  cluster_name    = aws_eks_cluster.nakodtech.name
  node_group_name = "nakodtech-node-group"
  node_role_arn   = aws_iam_role.nakodtech_node_group_role.arn
  subnet_ids      = aws_subnet.nakodtech_subnet[*].id

  scaling_config {
    desired_size = 3
    max_size     = 3
    min_size     = 3
  }

  instance_types = ["t3.medium"]

  remote_access {
    ec2_ssh_key               = var.ssh_key_name
    source_security_group_ids = [aws_security_group.nakodtech_node_sg.id]
  }

  depends_on = [
    aws_iam_role_policy_attachment.nakodtech_node_group_role_policy,
    aws_iam_role_policy_attachment.nakodtech_node_group_cni_policy,
    aws_iam_role_policy_attachment.nakodtech_node_group_registry_policy
  ]
}

############################
# OIDC + IRSA for EBS CSI
############################

# ------------------------------
# OIDC Provider for IRSA
# ------------------------------
resource "aws_iam_openid_connect_provider" "eks_oidc" {
  url             = aws_eks_cluster.nakodtech.identity[0].oidc[0].issuer
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = ["6938fd4d98bab03faadb97b34396831e3780aea1"]
}

# ------------------------------
# EBS CSI IRSA Policy Document
# ------------------------------
data "aws_iam_policy_document" "ebs_csi_assume" {
  statement {
    effect = "Allow"
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = [aws_iam_openid_connect_provider.eks_oidc.arn]
    }

    condition {
      test     = "StringEquals"
      variable = "${replace(aws_eks_cluster.nakodtech.identity[0].oidc[0].issuer, "https://", "")}:sub"
      values   = ["system:serviceaccount:kube-system:ebs-csi-controller-sa"]
    }

    condition {
      test     = "StringEquals"
      variable = "${replace(aws_eks_cluster.nakodtech.identity[0].oidc[0].issuer, "https://", "")}:aud"
      values   = ["sts.amazonaws.com"]
    }
  }
}

# ------------------------------
# EBS CSI IRSA Role
# ------------------------------
resource "aws_iam_role" "ebs_csi_irsa_role" {
  name               = "nakodtech-ebs-csi-irsa"
  assume_role_policy = data.aws_iam_policy_document.ebs_csi_assume.json
}

# ------------------------------
# Attach EBS CSI Policy to IRSA Role
# ------------------------------
resource "aws_iam_role_policy_attachment" "ebs_csi_policy_attach" {
  role       = aws_iam_role.ebs_csi_irsa_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
}

############################
# Wait for nodes
############################

# ------------------------------
# Wait for nodes ready (local-exec)
# ------------------------------
resource "null_resource" "wait_for_nodes_ready" {
  provisioner "local-exec" {
    command = <<EOT
      set -e
      echo "Updating kubeconfig..."
      aws eks update-kubeconfig --region us-east-1 --name ${aws_eks_cluster.nakodtech.name}
      echo "Waiting for nodes..."
      kubectl wait --for=condition=Ready nodes --all --timeout=10m
    EOT
    interpreter = ["/bin/bash", "-c"]
  }

  triggers = {
    cluster_name = aws_eks_cluster.nakodtech.name
    nodegroup_id = aws_eks_node_group.nakodtech.id
  }

  depends_on = [aws_eks_node_group.nakodtech]
}

############################
# EBS CSI Driver Addon
############################

# ------------------------------
# EBS CSI Driver Addon (uses IRSA)
# ------------------------------
resource "aws_eks_addon" "ebs_csi_driver" {
  cluster_name             = aws_eks_cluster.nakodtech.name
  addon_name               = "aws-ebs-csi-driver"
  service_account_role_arn = aws_iam_role.ebs_csi_irsa_role.arn

  resolve_conflicts_on_create = "OVERWRITE"
  resolve_conflicts_on_update = "OVERWRITE"

  depends_on = [
    aws_eks_node_group.nakodtech,
    aws_iam_openid_connect_provider.eks_oidc,
    aws_iam_role_policy_attachment.ebs_csi_policy_attach,
    null_resource.wait_for_nodes_ready
  ]
}

############################
# NAT Gateways & Private Routing (NEW)
############################

# ------------------------------
# Elastic IPs for NAT Gateways (2)
# ------------------------------
# Allocate an EIP per NAT Gateway (one per AZ)
resource "aws_eip" "nat_eip" {
  count = 2

  tags = {
    Name = "nakodtech-nat-eip-${count.index}"
  }
}

# ------------------------------
# NAT Gateways (2)
# ------------------------------
# Create one NAT Gateway in each public subnet so private subnets can reach the internet
resource "aws_nat_gateway" "nakodtech_nat" {
  count = 2
  allocation_id = aws_eip.nat_eip[count.index].id
  subnet_id     = aws_subnet.nakodtech_subnet[count.index].id

  tags = {
    Name = "nakodtech-nat-${count.index}"
  }

  depends_on = [
    aws_internet_gateway.nakodtech_igw
  ]
}

# ------------------------------
# Private Route Tables (one per AZ) - FIXED
# ------------------------------
# Create a private route table per AZ and add a 0.0.0.0/0 -> NAT route in each.
resource "aws_route_table" "nakodtech_private_route_table" {
  count  = 2
  vpc_id = aws_vpc.nakodtech_vpc.id

  tags = {
    Name = "nakodtech-private-route-table-${count.index}"
  }
}

# ------------------------------
# Private Route -> NAT (per AZ) - FIXED
# ------------------------------
# Adds a route to each private route table that sends 0.0.0.0/0 to its NAT Gateway
resource "aws_route" "private_route_via_nat" {
  count                  = 2
  route_table_id         = aws_route_table.nakodtech_private_route_table[count.index].id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nakodtech_nat[count.index].id

  depends_on = [
    aws_nat_gateway.nakodtech_nat
  ]
}

# ------------------------------
# Private Route Table Associations - FIXED
# ------------------------------
# Associates each private route table with its private subnet in the same AZ
resource "aws_route_table_association" "nakodtech_private_assoc" {
  count          = 2
  subnet_id      = aws_subnet.nakodtech_private_subnet[count.index].id
  route_table_id = aws_route_table.nakodtech_private_route_table[count.index].id
}
