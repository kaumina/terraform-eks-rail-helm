# Create and attach policies to assum role which used by EKS service to access other AWS services.

resource "aws_iam_role" "eks-rail-cluster" {
  name = "eks-rail-cluster"

  assume_role_policy = <<POLICY
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
POLICY
}

resource "aws_iam_role_policy_attachment" "eks-rail-cluster-AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = "${aws_iam_role.eks-rail-cluster.name}"
}

resource "aws_iam_role_policy_attachment" "eks-rail-cluster-AmazonEKSServicePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSServicePolicy"
  role       = "${aws_iam_role.eks-rail-cluster.name}"
}

# Create the security group for EKS masters

resource "aws_security_group" "eks-rails-cluster" {
  name        = "eks-demo-rail-cluster"
  description = "Cluster communication with worker nodes"
  vpc_id      = "${aws_vpc.eks-rail-vpc.id}"

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "eks-rail-sg"
  }
}

# OPTIONAL: Allow inbound traffic from your local workstation external IP
#           to the Kubernetes. You will need to replace A.B.C.D below with
#           your real IP. Services like icanhazip.com can help you find this.
resource "aws_security_group_rule" "eks-rail-cluster-ingress-workstation-https" {
  cidr_blocks       = ["123.231.105.78/32"]
  description       = "Allow workstation to communicate with the cluster API Server"
  from_port         = 443
  protocol          = "tcp"
  security_group_id = "${aws_security_group.eks-rails-cluster.id}"
  to_port           = 443
  type              = "ingress"
}
