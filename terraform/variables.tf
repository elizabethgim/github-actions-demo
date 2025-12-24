variable "kubernetes_config_path" {
  default = "~/.kube/config"
}

variable "container_image_be" {
  type = string
}

variable "container_image_fe" {
  type = string
}

variable "backend_url" {
  type = string
}

variable "frontend_url" {
  type = string
}

# variable "backend_image" {
#   type        = string
#   description = "ECR image for backend (e.g., <acct>.dkr.ecr.<region>.amazonaws.com/calc-be:latest)"
# }

# variable "frontend_image" {
#   type        = string
#   description = "ECR image for frontend (e.g., <acct>.dkr.ecr.<region>.amazonaws.com/calc-fe:latest)"
# }
