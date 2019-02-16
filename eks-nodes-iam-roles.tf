# Create iam roles for eks nodes
resource "aws_iam_role" "eks-rails-node-role" {
  name = "eks-rails-node-role"

  assume_role_policy = <<POLICY
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
POLICY
}

# Attach AmazonEKSWorkerNodePolicy
resource "aws_iam_role_policy_attachment" "eks-rails-node-AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = "${aws_iam_role.eks-rails-node-role.name}"
}

# Attach AmazonEKS_CNI_Policy
resource "aws_iam_role_policy_attachment" "eks-rails-node-AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = "${aws_iam_role.eks-rails-node-role.name}"
}
# Attach AmazonEC2ContainerRegistryReadOnly
resource "aws_iam_role_policy_attachment" "eks-rails-node-AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = "${aws_iam_role.eks-rails-node-role.name}"
}

# Attach instance profile to the role
resource "aws_iam_instance_profile" "eks-rails-node-instance-profile" {
  name = "eks-rails-node"
  role = "${aws_iam_role.eks-rails-node-role.name}"
}
