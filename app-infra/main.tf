module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "4.0.0"

  name = "app-vpc"
  cidr = "10.0.0.0/16"

  azs             = ["us-east-1a", "us-east-1b"]
  private_subnets = []
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24"]

  enable_nat_gateway = false
    Name = "app-vpc"
  }
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "19.0.0"

  cluster_name    = "lanchonete-cluster"
  cluster_version = "1.27"

  subnets         = module.vpc.public_subnets
  vpc_id          = module.vpc.vpc_id

  node_groups = {
    lanchonete-nodes = {
      desired_capacity = 1
      max_capacity     = 1
      min_capacity     = 1

      instance_types = ["t3.micro"]
    }
  }

  tags = {
    Environment = "Dev"
  }
}

resource "aws_iam_role_policy_attachment" "alb_controller" {
  role       = module.eks.alb_ingress_role_name
  policy_arn = "arn:aws:iam::aws:policy/ElasticLoadBalancingFullAccess"
}

resource "aws_security_group" "eks_alb" {
  name_prefix = "eks-alb-sg"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description = "Allow HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}