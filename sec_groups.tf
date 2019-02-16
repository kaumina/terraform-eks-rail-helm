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

# Setting up security groups for EKS nodes
resource "aws_security_group" "eks-rails-node-sg" {
  name        = "eks-rails-node-sg"
  description = "Security group for all nodes in the cluster"
  vpc_id      = "${aws_vpc.eks-rail-vpc.id}"

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = "${
    map(
     "Name", "eks-rail-node",
     "kubernetes.io/cluster/${var.cluster-name}", "owned",
    )
  }"
}

resource "aws_security_group_rule" "eks-rails-node-ingress-self" {
  description              = "Allow node to communicate with each other"
  from_port                = 0
  protocol                 = "-1"
  security_group_id        = "${aws_security_group.eks-rails-node-sg.id}"
  source_security_group_id = "${aws_security_group.eks-rails-node-sg.id}"
  to_port                  = 65535
  type                     = "ingress"
}

resource "aws_security_group_rule" "eks-rails-node-ingress-cluster" {
  description              = "Allow worker Kubelets and pods to receive communication from the cluster control plane"
  from_port                = 1025
  protocol                 = "tcp"
  security_group_id        = "${aws_security_group.eks-rails-node-sg.id}"
  source_security_group_id = "${aws_security_group.eks-rails-cluster.id}"
  to_port                  = 65535
  type                     = "ingress"
}

# Open ports for pods to communicate with api server (from pods to api)
resource "aws_security_group_rule" "eks-rails-cluster-ingress-node-https" {
  description              = "Allow pods to communicate with the cluster API Server"
  from_port                = 443
  protocol                 = "tcp"
  security_group_id        = "${aws_security_group.eks-rails-cluster.id}"
  source_security_group_id = "${aws_security_group.eks-rails-node-sg.id}"
  to_port                  = 443
  type                     = "ingress"
}
