resource "kubernetes_deployment" "frontend" {
  metadata {
    name      = "frontend"
    namespace = "calc"
    labels = {
      run = "calc-frontend"
    }
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        run = "calc-frontend"
      }
    }

    template {
      metadata {
        labels = {
          run = "calc-frontend"
        }
      }

      spec {
        # ✅ ECR private registry pull secret 연결 (main.tf에서 만든 aws_ecr_cred 사용)
        image_pull_secrets {
          name = kubernetes_secret.aws_ecr_cred.metadata[0].name
        }

        container {
          name              = "frontend"
          image             = var.container_image_fe
          image_pull_policy = "Always"

          port {
            container_port = 3000
          }

          env {
            name  = "REACT_APP_BACKEND_URL"
            value = var.backend_url
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "frontend" {
  metadata {
    name      = "frontend"
    namespace = "calc"
  }

  spec {
    type = "NodePort"

    selector = {
      run = "calc-frontend"
    }

    port {
      port      = 3000
      node_port = 30030
    }
  }
}
