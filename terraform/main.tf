terraform {

  backend "s3" {
    bucket         = "cas3135-2025-tfstates"
    key            = "cas3135-2024148030/calc-k8s.tfstate"
    region         = "ap-northeast-2"
    dynamodb_table = "cas3135-terraform-locks"
    encrypt        = true
  }
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.29"
    }
  }
  required_version = ">= 1.5.0"
}

provider "kubernetes" {
  config_path = var.kubernetes_config_path
}

resource "kubernetes_namespace" "ns" {
  metadata {
    name = "calc"
  }
}

# ECR 로그인 토큰 (임시)
data "aws_ecr_authorization_token" "ecr_token" {}

# k8s secret: ECR private registry pull credentials
resource "kubernetes_secret" "aws_ecr_cred" {
  metadata {
    name      = "aws-ecr-cred"
    namespace = "calc"
  }

  type = "kubernetes.io/dockerconfigjson"

  data = {
    ".dockerconfigjson" = jsonencode({
      auths = {
        "${data.aws_ecr_authorization_token.ecr_token.proxy_endpoint}" = {
          username = data.aws_ecr_authorization_token.ecr_token.user_name
          password = data.aws_ecr_authorization_token.ecr_token.password
          auth     = data.aws_ecr_authorization_token.ecr_token.authorization_token
        }
      }
    })
  }
}

