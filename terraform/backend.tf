resource "kubernetes_config_map" "backend_config" {
  metadata {
    name      = "backend-config"
    namespace = "calc"
  }

  data = {
    FRONTEND_URL = var.frontend_url
  }
}

resource "kubernetes_deployment" "backend" {
  metadata {
    name      = "backend"
    namespace = "calc"
    labels = {
      run = "calc-backend"
    }
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        run = "calc-backend"
      }
    }

    template {
      metadata {
        labels = {
          run = "calc-backend"
        }
      }

      spec {
        # ✅ ECR private registry pull secret 연결 (main.tf에서 만든 aws_ecr_cred 사용)
        image_pull_secrets {
          name = kubernetes_secret.aws_ecr_cred.metadata[0].name
        }

        container {
          name              = "backend"
          image             = var.container_image_be
          image_pull_policy = "Always"

          port {
            container_port = 3031
          }

          env_from {
            config_map_ref {
              name = "backend-config"
            }
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "backend" {
  metadata {
    name      = "backend"
    namespace = "calc"
  }

  spec {
    type = "NodePort"

    selector = {
      run = "calc-backend"
    }

    port {
      port      = 3031
      node_port = 30031
    }
  }
}
