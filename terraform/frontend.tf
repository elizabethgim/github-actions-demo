resource "kubernetes_deployment" "frontend" {
  metadata {
    name = "frontend"
    namespace = "calc"
  }
  spec {
    selector {
      match_labels = {
        run = "calc-frontend"
      }
    }
    replicas = 1
    template {
      metadata {
        labels = {
          run = "calc-frontend"
        }
      }
      spec {
        image_pull_secrets {
					name = kubernetes_secret.aws_ecr_cred.metadata[0].name
				}
        container {
          name = "frontend"
          image = var.container_image_fe
          image_pull_policy = "Always"
          port {
            container_port = 3000
          }
          env {
            name = "REACT_APP_BACKEND_URL"
            value = var.backend_url
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "frontend" {
  metadata {
    name = "frontend"
    namespace = "calc"
  }
  spec {
    type = "NodePort"
    selector = {
      run = "calc-frontend"
    }
    port {
      port = 3000
      node_port = 30030
    }
  }
}