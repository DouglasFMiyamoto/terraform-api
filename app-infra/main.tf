module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "4.0.0"

  name = "app-vpc"
  cidr = "10.0.0.0/16"

  azs             = ["us-east-1a", "us-east-1b"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24"]

  enable_nat_gateway = true
  tags = {
    Name = "app-vpc"
  }
}

module "eks" {
  source = "terraform-aws-modules/eks/aws"
  version = "18.21.0"

  cluster_name = "lanchonete-cluster"
  cluster_version = "1.27"
  vpc_id = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets

  eks_managed_node_groups = {
    lanchonete-nodes = {
      desired_capacity = 2
      max_capacity     = 3
      min_capacity     = 1
      instance_types   = ["t3.small"]
      key_name         = var.key_name
    }
  }

  tags = {
    Environment = "Dev"
  }
}

resource "aws_iam_role_policy_attachment" "alb_controller" {
  role       = module.eks.cluster_iam_role_name  # Corrigido para acessar o atributo correto
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