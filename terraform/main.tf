terraform {
  backend "s3" {
    bucket = "cas3135-2025-tfstates"
    key = "cas3135-2021147608/calc-k8s"
    dynamodb_table = "cas3135-terraform-locks"
    region = "ap-northeast-2"
    encrypt = true
  }
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.29"
    }
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
  required_version = ">= 1.5.0"
}

provider "kubernetes" {
  config_path = var.kubernetes_config_path
}

data "aws_ecr_authorization_token" "ecr_token" {
}

resource "kubernetes_secret" "aws_ecr_cred" {
	metadata {
		name = "aws-ecr-cred"
		namespace = "calc"
	}
	type = "kubernetes.io/dockerconfigjson"
	data = {
		".dockerconfigjson" = jsonencode({
			auths = {
				"${data.aws_ecr_authorization_token.ecr_token.proxy_endpoint}" = {
					username = data.aws_ecr_authorization_token.ecr_token.user_name
					password = data.aws_ecr_authorization_token.ecr_token.password
					auth = data.aws_ecr_authorization_token.ecr_token.authorization_token
				}
			}
		})
	}
}

resource "kubernetes_namespace" "ns" {
  metadata {
    name = "calc"
  }
}