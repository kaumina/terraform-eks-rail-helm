#######################################################################################
#        This tf will create AWS networking components:VPC, Subnets, IG and routes
########################################################################################

data "aws_availability_zones" "available" {}
provider "aws" {
  region     = "us-east-1"
}
# Create VPC
resource "aws_vpc" "eks-rail-vpc" {
  cidr_block = "10.0.0.0/16"

  tags = "${
    map(
     "Name", "eks-rail-vpc",
     "kubernetes.io/cluster/${var.cluster-name}", "shared",
    )
  }"
}

# Create subnet
resource "aws_subnet" "eks-rail-subnet" {
  count = 2

  availability_zone = "${data.aws_availability_zones.available.names[count.index]}"
  cidr_block        = "10.0.${count.index}.0/24"
  vpc_id            = "${aws_vpc.eks-rail-vpc.id}"

  tags = "${
    map(
     "Name", "eks-rail-node-subnet",
     "kubernetes.io/cluster/${var.cluster-name}", "shared",
    )
  }"
}

# Create Internet gateway
resource "aws_internet_gateway" "eks-rail-gw" {
  vpc_id = "${aws_vpc.eks-rail-vpc.id}"

  tags = {
    Name = "eks-rail-gw"
  }
}

resource "aws_route_table" "eks-rail-route-table" {
  vpc_id = "${aws_vpc.eks-rail-vpc.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.eks-rail-gw.id}"
  }
  
  tags = {
    Name = "eks-rail-route"
  }
}

resource "aws_route_table_association" "eks-rail-route" {
  count = 2

  subnet_id      = "${aws_subnet.eks-rail-subnet.*.id[count.index]}"
  route_table_id = "${aws_route_table.eks-rail-route-table.id}"
}
