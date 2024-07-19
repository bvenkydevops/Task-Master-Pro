output "cluster_id" {
  value = aws_eks_cluster.venky.id
}
output "node_group_id" {
  value = aws_eks_node_group.venky.id
}
output "vpc_id" {
  value = aws_vpc.venky_vpc.id
}
output "subnet_ids" {
  value = aws_subnet.venky_subnet[*].id
}