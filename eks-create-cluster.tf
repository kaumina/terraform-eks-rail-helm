#######################################################################################
#             This tf will create EKS cluster
########################################################################################

# Create EKS cluster
resource "aws_eks_cluster" "eks-rail" {
  name            = "${var.cluster-name}"
  role_arn        = "${aws_iam_role.eks-rail-cluster.arn}"
  vpc_config {
    security_group_ids = ["${aws_security_group.eks-rails-cluster.id}"]
    subnet_ids         = ["${aws_subnet.eks-rail-subnet.*.id}"]
  }
  depends_on = [
    "aws_iam_role_policy_attachment.eks-rail-cluster-AmazonEKSClusterPolicy",
    "aws_iam_role_policy_attachment.eks-rail-cluster-AmazonEKSServicePolicy",
  ]
}
