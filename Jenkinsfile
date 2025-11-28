pipeline {
  agent any
  environment {
    DOCKERHUB_CRED = 'dockerhub-creds' // Jenkins credential id
    DOCKERHUB_REPO = 'yourdockerhubusername/trend-app'
    KUBECONFIG_CRED = 'kubeconfig'     // store kubeconfig in Jenkins credentials
  }

  stages {
    stage('Checkout') {
      steps { checkout scm }
    }

    stage('Build app') {
      steps {
        sh 'npm ci --legacy-peer-deps'
        sh 'npm run build'
      }
    }

    stage('Build Docker') {
      steps {
        sh 'docker build -t $DOCKERHUB_REPO:$BUILD_NUMBER .'
      }
    }

    stage('Push to Docker Hub') {
      steps {
        withCredentials([usernamePassword(credentialsId: env.DOCKERHUB_CRED, usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
          sh 'echo $DOCKER_PASS | docker login -u $DOCKER_USER --password-stdin'
          sh 'docker push $DOCKERHUB_REPO:$BUILD_NUMBER'
        }
      }
    }

    stage('Deploy to Kubernetes') {
      steps {
        withCredentials([file(credentialsId: env.KUBECONFIG_CRED, variable: 'KUBECONFIG_FILE')]) {
          sh 'mkdir -p ~/.kube && cp $KUBECONFIG_FILE ~/.kube/config && chmod 600 ~/.kube/config'
          sh "kubectl set image deployment/trend-deployment trend-container=$DOCKERHUB_REPO:$BUILD_NUMBER --namespace default || kubectl apply -f k8s/deployment.yaml"
        }
      }
    }
  }
  post {
    always { echo "Pipeline finished: ${currentBuild.fullDisplayName}" }
  }
}
