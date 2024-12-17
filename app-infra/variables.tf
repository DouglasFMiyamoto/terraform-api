variable "region" {
  description = "AWS region"
  default     = "us-east-1"
}

variable "eks_cluster_name" {
  description = "Name of the EKS cluster"
  default     = "lanchonete-cluster"
}

variable "key_name" {
  description = "Nome da chave SSH para os nós do EKS"
  type        = string
  default     = "ec2-key-pair"
}