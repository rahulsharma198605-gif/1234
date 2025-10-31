pipeline {
  agent any

  environment {
    // ====== CHANGE THESE IF NEEDED ======
    DOCKERHUB_USER = 'rahul5553'
    IMAGE_NAME     = '1234'
    APP_NAME       = 'flask-app'   // Kubernetes Deployment name
    CONTAINER_NAME = 'flask'       // container name in the Deployment spec
    // ====================================

    IMAGE_TAG      = "${env.BUILD_NUMBER}"
    KUBECONFIG     = 'C:\\Users\\Rahul\\.kube\\config'
    MINIKUBE_HOME  = 'C:\\Users\\Rahul\\.minikube'

    DEPLOYMENT_YAML = 'deployment.yaml'
    SERVICE_YAML    = 'service.yaml'
  }

  options {
    disableConcurrentBuilds()
    timestamps()
  }

  stages {

    stage('Checkout') {
      steps {
        echo '📥 Checking out code...'
        checkout scm
      }
    }

    stage('Build Docker Image') {
      steps {
        echo "🛠 Building Docker image: ${DOCKERHUB_USER}/${IMAGE_NAME}:${IMAGE_TAG}"
        bat """
          docker build -t ${DOCKERHUB_USER}/${IMAGE_NAME}:${IMAGE_TAG} -t ${DOCKERHUB_USER}/${IMAGE_NAME}:latest .
        """
      }
    }

    stage('Login & Push to Docker Hub') {
      steps {
        echo '🔐 Logging in & pushing image...'
        withCredentials([usernamePassword(credentialsId: 'docker-hub-creds', usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
          bat """
            docker login -u %DOCKER_USER% -p %DOCKER_PASS%
            docker push ${DOCKERHUB_USER}/${IMAGE_NAME}:${IMAGE_TAG}
            docker push ${DOCKERHUB_USER}/${IMAGE_NAME}:latest
          """
        }
      }
    }

    stage('Kube Context (minikube)') {
      steps {
        echo '🔧 Point kubectl to minikube'
        bat """
          minikube update-context
          kubectl config use-context minikube
          kubectl get nodes
        """
      }
    }

    stage('Apply Base Manifests') {
      steps {
        echo '📄 Ensure resources exist'
        bat """
          kubectl apply -f ${DEPLOYMENT_YAML}
          kubectl apply -f ${SERVICE_YAML}
          kubectl get deploy,svc
        """
      }
    }

    stage('Update Image & Rollout (with rollback)') {
      steps {
        script {
          echo "🚀 Setting image to ${DOCKERHUB_USER}/${IMAGE_NAME}:${IMAGE_TAG} and rolling out…"

          // Show history before change (for visibility)
          bat "kubectl rollout history deployment/${APP_NAME}"

          // Try the rollout; if it fails, rollback
          try {
            // Set the new image (this creates a new ReplicaSet)
            bat """
              kubectl set image deployment/${APP_NAME} ${CONTAINER_NAME}=${DOCKERHUB_USER}/${IMAGE_NAME}:${IMAGE_TAG}
            """

            // Wait for rollout success (timeout if not healthy)
            bat """
              kubectl rollout status deployment/${APP_NAME} --timeout=120s
            """

            echo "✅ Rollout healthy for image tag ${IMAGE_TAG}"
          } catch (err) {
            echo "❌ Rollout failed. Rolling back…"
            // Undo to previous working ReplicaSet
            bat "kubectl rollout undo deployment/${APP_NAME}"
            // Optional: wait for the rollback to become healthy
            bat "kubectl rollout status deployment/${APP_NAME} --timeout=120s"
            error("Rollback executed due to failed rollout.")
          }

          // Show history after change
          bat "kubectl rollout history deployment/${APP_NAME}"
        }
      }
    }
  }

  post {
    success {
      echo "✅ Build #${env.BUILD_NUMBER} OK — deployed ${DOCKERHUB_USER}/${IMAGE_NAME}:${IMAGE_TAG}"
      bat "kubectl get deploy,po,svc -o wide"
    }
    failure {
      echo "❌ Build failed. Check logs above (push/rollout/rollback details)."
      bat "kubectl get deploy,po,svc -o wide || ver > nul"
    }
    always {
      echo '📜 Pipeline finished.'
    }
  }
}
