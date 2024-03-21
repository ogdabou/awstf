resource "aws_vpc" "eks" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "demo-vpc"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.eks.id

  tags = {
    Name = "igw"
  }
}

resource "aws_subnet" "private-eu-west-1a" {
  vpc_id            = aws_vpc.eks.id
  cidr_block        = "10.0.0.0/19"
  availability_zone = "eu-west-1a"

  tags = {
    "Name"                            = "eu-west-1a"
    "kubernetes.io/role/internal-elb" = "1"
    "kubernetes.io/cluster/demo"      = "owned"
  }
}

resource "aws_subnet" "public-eu-west-1a" {
  vpc_id                  = aws_vpc.eks.id
  cidr_block              = "10.0.64.0/19"
  availability_zone       = "eu-west-1a"
  map_public_ip_on_launch = true

  tags = {
    "Name"                       = "eu-west-1a"
    "kubernetes.io/role/elb"     = "1"
    "kubernetes.io/cluster/demo" = "owned"
  }
}

resource "aws_eip" "nat" {
  vpc = true

  tags = {
    Name = "nat"
  }
}

resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.private-eu-west-1a.id

  tags = {
    Name = "nat"
  }

  depends_on = [aws_internet_gateway.igw]
}
#
#resource "aws_route_table" "private" {
#  vpc_id = aws_vpc.eks.id
#
#  route = [
#    {
#      cidr_block                 = "0.0.0.0/0"
#      nat_gateway_id             = aws_nat_gateway.nat.id
#      carrier_gateway_id         = ""
#      destination_prefix_list_id = ""
#      egress_only_gateway_id     = ""
#      gateway_id                 = ""
#      instance_id                = ""
#      ipv6_cidr_block            = ""
#      local_gateway_id           = ""
#      network_interface_id       = ""
#      transit_gateway_id         = ""
#      vpc_endpoint_id            = ""
#      vpc_peering_connection_id  = ""
#    },
#  ]
#
#  tags = {
#    Name = "private"
#  }
#}
#
#resource "aws_route_table" "public" {
#  vpc_id = aws_vpc.eks.id
#
#  route = [
#    {
#      cidr_block                 = "0.0.0.0/0"
#      gateway_id                 = aws_internet_gateway.igw.id
#      nat_gateway_id             = ""
#      carrier_gateway_id         = ""
#      destination_prefix_list_id = ""
#      egress_only_gateway_id     = ""
#      instance_id                = ""
#      ipv6_cidr_block            = ""
#      local_gateway_id           = ""
#      network_interface_id       = ""
#      transit_gateway_id         = ""
#      vpc_endpoint_id            = ""
#      vpc_peering_connection_id  = ""
#    },
#  ]
#
#  tags = {
#    Name = "public"
#  }
#}

#resource "aws_route_table_association" "private-eu-west-1a" {
#  subnet_id      = aws_subnet.private-eu-west-1a.id
#  route_table_id = aws_route_table.private.id
#}
#
#
#resource "aws_route_table_association" "public-eu-west-1a" {
#  subnet_id      = aws_subnet.public-eu-west-1a.id
#  route_table_id = aws_route_table.public.id
#}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.0"

  cluster_name    = "awstf2"
  cluster_version = "1.29"

  cluster_endpoint_public_access  = true

  cluster_addons = {
    coredns = {
      most_recent = true
    }
    kube-proxy = {
      most_recent = true
    }
    vpc-cni = {
      most_recent = true
    }
  }

  vpc_id                   = aws_vpc.eks.id
  subnet_ids               = [aws_subnet.public-eu-west-1a.id, aws_subnet.private-eu-west-1a.id]
  control_plane_subnet_ids = [aws_subnet.private-eu-west-1a.id]

  # EKS Managed Node Group(s)
  eks_managed_node_group_defaults = {
    instance_types = ["t3.small"]
  }

  eks_managed_node_groups = {
    example = {
      min_size     = 1
      max_size     = 2
      desired_size = 1

      instance_types = ["t3.small"]
      capacity_type  = "SPOT"
    }
  }

  # Cluster access entry
  # To add the current caller identity as an administrator
  enable_cluster_creator_admin_permissions = true

  access_entries = {
    # One access entry with a policy associated
    example = {
      kubernetes_groups = []
      principal_arn     = var.admin_arn

      policy_associations = {
        example = {
          policy_arn = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSViewPolicy"
          access_scope = {
            namespaces = ["default"]
            type       = "namespace"
          }
        }
      }
    }
  }

  tags = {
    Environment = "dev"
    Terraform   = "true"
  }
}