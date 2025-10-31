pipeline {
  agent any

  environment {
    // ====== CHANGE THESE 2 ======
    DOCKERHUB_USER = 'rahul5553'
    IMAGE_NAME     = '1234'
    // ============================

    // Tag image with Jenkins build number and also 'latest'
    IMAGE_TAG   = "${env.BUILD_NUMBER}"

    // Tell kubectl/minikube where to find your local configs (Windows paths)
    // Make sure these paths exist for the Jenkins service account.
    KUBECONFIG   = 'C:\\Users\\Rahul\\.kube\\config'
    MINIKUBE_HOME= 'C:\\Users\\Rahul\\.minikube'

    // Optional: pin the manifest paths (committed in repo)
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
          docker version
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
        echo '🔧 Ensuring kubectl talks to minikube...'
        // If Jenkins runs as a different user, ensure KUBECONFIG/MINIKUBE_HOME point to that user’s files or run Jenkins as Rahul.
        bat """
          where kubectl
          where minikube
          minikube status
          minikube update-context
          kubectl config use-context minikube
          kubectl cluster-info
          kubectl get nodes
        """
      }
    }

    stage('Deploy to Kubernetes') {
      steps {
        echo '🚀 Applying manifests...'
        bat """
          kubectl apply -f ${DEPLOYMENT_YAML}
          kubectl apply -f ${SERVICE_YAML}
          kubectl rollout status deployment/flask-app --timeout=120s
          kubectl get deploy,po,svc -o wide
        """
      }
    }
  }

  post {
    success {
      echo "✅ Build #${env.BUILD_NUMBER} OK — deployed ${DOCKERHUB_USER}/${IMAGE_NAME}:${IMAGE_TAG}"
    }
    failure {
      echo "❌ Build failed. Check which stage broke (Docker build/push or kubectl)."
    }
    always {
      echo '📜 Pipeline finished.'
    }
  }
}
