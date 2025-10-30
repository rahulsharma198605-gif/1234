pipeline {
    agent any

    environment {
        DOCKERHUB_USER = 'rahul5553'
        IMAGE_NAME     = 'devops-practice-1'
        TAG            = "${env.BUILD_NUMBER}"
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Docker Build') {
            steps {
                echo "🛠 Building image %DOCKERHUB_USER%/%IMAGE_NAME%:%TAG%"
                bat '''
                docker build -t %DOCKERHUB_USER%/%IMAGE_NAME%:%TAG% -t %DOCKERHUB_USER%/%IMAGE_NAME%:latest .
                '''
            }
        }

        stage('Docker Login') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'dockerhub', usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
                    bat 'docker login -u %DOCKER_USER% -p %DOCKER_PASS%'
                }
            }
        }

        stage('Docker Push') {
            steps {
                bat '''
                docker push %DOCKERHUB_USER%/%IMAGE_NAME%:%TAG%
                docker push %DOCKERHUB_USER%/%IMAGE_NAME%:latest
                '''
            }
        }
    }

    post {
        always {
            echo '✅ Docker stage finished.'
            bat 'docker images'
        }
    }
}