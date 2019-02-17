#######################################################################################
#             This tf will enable autoscaling to nodes
########################################################################################


# Pull the EKS ami for nodes provided by Amazon
data "aws_ami" "eks-worker" {
  filter {
    name   = "name"
    values = ["amazon-eks-node-${aws_eks_cluster.eks-rail.version}-v*"]
  }

  most_recent = true
  owners      = ["602401143452"] # Amazon EKS AMI Account ID
}

# Launch and prepare the node.
data "aws_region" "current" {}

# Add the user data for node to get joined to EKS cluster.
locals {
  eks-node-userdata = <<USERDATA
#!/bin/bash
set -o xtrace
/etc/eks/bootstrap.sh --apiserver-endpoint '${aws_eks_cluster.eks-rail.endpoint}' --b64-cluster-ca '${aws_eks_cluster.eks-rail.certificate_authority.0.data}' '${var.cluster-name}'
USERDATA
}

# Create the launch configuration
resource "aws_launch_configuration" "eks-rails-launchconfig" {
  associate_public_ip_address = true
  iam_instance_profile        = "${aws_iam_instance_profile.eks-rails-node-instance-profile.name}"
  image_id                    = "${data.aws_ami.eks-worker.id}"
  instance_type               = "t2.medium"
  name_prefix                 = "terraform-eks-rail"
  security_groups             = ["${aws_security_group.eks-rails-node-sg.id}"]
  user_data_base64            = "${base64encode(local.eks-node-userdata)}"

  lifecycle {
    create_before_destroy = true
  }
}

# Create auto scaling group for EKS nodes cluster
resource "aws_autoscaling_group" "eks-rails-nodes-autoscaling-group" {
  desired_capacity     = 3
  launch_configuration = "${aws_launch_configuration.eks-rails-launchconfig.id}"
  max_size             = 5
  min_size             = 1
  name                 = "terraform-eks-rail"
  vpc_zone_identifier  = ["${aws_subnet.eks-rail-subnet.*.id}"]

  tag {
    key                 = "Name"
    value               = "terraform-eks-rail"
    propagate_at_launch = true
  }

  tag {
    key                 = "kubernetes.io/cluster/${var.cluster-name}"
    value               = "owned"
    propagate_at_launch = true
  }
}
