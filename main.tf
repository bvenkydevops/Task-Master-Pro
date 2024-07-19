# Configure the AWS Provider
provider "aws" {
  region = "ap-south-1"
}

# Create a VPC
resource "aws_vpc" "venky_vpc" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "venky-vpc"
  }
}

# Create subnets
resource "aws_subnet" "venky_subnet" {
  count = 2

  vpc_id = aws_vpc.venky_vpc.id
  cidr_block = cidrsubnet(aws_vpc.venky_vpc.cidr_block, 8, count.index)
  availability_zone = element(["ap-south-1a", "ap-south-1b"], count.index)
  map_public_ip_on_launch = true

  tags = {
    Name = "venky-subnet_${count.index}"
  }
}

# Create internet gateway
resource "aws_internet_gateway" "venky_igw" {
  vpc_id = aws_vpc.venky_vpc.id

  tags = {
    Name = "venky-igw"
  }
}

# Create route table
resource "aws_route_table" "venky_route_table" {
  vpc_id = aws_vpc.venky_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.venky_igw.id
  }

  tags = {
    Name = "venky-route-table"
  }
}

# Route table association
resource "aws_route_table_association" "a" {
  count = 2

  subnet_id = aws_subnet.venky_subnet[count.index].id
  route_table_id = aws_route_table.venky_route_table.id
}

# Create security group for cluster
resource "aws_security_group" "venky_cluster_sg" {
  vpc_id = aws_vpc.venky_vpc.id

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "venky-cluster-sg"
  }
}

# Create security group for node
resource "aws_security_group" "venky_node_sg" {
  vpc_id = aws_vpc.venky_vpc.id

  ingress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "venky-node-sg"
  }
}

# Create EKS cluster
resource "aws_eks_cluster" "venky" {
  name     = "venky_cluster"
  role_arn = aws_iam_role.venky_cluster_role.arn

  vpc_config {
    subnet_ids         = aws_subnet.venky_subnet[*].id
    security_group_ids = [aws_security_group.venky_cluster_sg.id]
  }
}

# Create Node group
resource "aws_eks_node_group" "venky" {
  cluster_name    = aws_eks_cluster.venky.name
  node_group_name = "venky-node-group"
  node_role_arn   = aws_iam_role.venky_node_group_role.arn
  subnet_ids      = aws_subnet.venky_subnet[*].id

  scaling_config {
    desired_size = 3
    max_size     = 3
    min_size     = 3
  }

  instance_types = ["t2.medium"]

  remote_access {
    ec2_ssh_key = var.ssh_key_name
    source_security_group_ids = [aws_security_group.venky_node_sg.id]
  }
}

# Create IAM roles
resource "aws_iam_role" "venky_cluster_role" {
  name = "venky-cluster-role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "eks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "venky_cluster_role_policy" {
  role       = aws_iam_role.venky_cluster_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

resource "aws_iam_role" "venky_node_group_role" {
  name = "venky-node-group-role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "venky_node_group_role_policy" {
  role       = aws_iam_role.venky_node_group_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}

resource "aws_iam_role_policy_attachment" "venky_node_group_role_cni_policy" {
  role       = aws_iam_role.venky_node_group_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
}

resource "aws_iam_role_policy_attachment" "venky_node_group_registry_policy" {
  role       = aws_iam_role.venky_node_group_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}
