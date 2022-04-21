pipeline {
    agent any
    environment {
        DOCKERHUB_CREDENTIALS=credentials('docker-hub-credentials')
        CLOUDSDK_CORE_DISABLE_PROMPTS=1
        SHA=sh(script: 'git rev-parse HEAD', returnStdout: true).trim()

        PROJECT_ID = 'multi-k8s-347813'
        CLUSTER_NAME = 'multi-cluster'
        LOCATION = 'us-central1-c'
        CREDENTIALS_ID = credentials('multi-k8s-347813')
    }
    stages {
        stage('Test') {
            steps {
                sh '''
                    docker build -t estonezzz/react-test -f ./client/Dockerfile.dev ./client
                    docker run -e CI=true estonezzz/react-test npm test
                '''
            }            
        }
        stage('Build') {
            steps {
                sh '''
                    docker build -t estonezzz/multi-client:latest -t estonezzz/multi-client:${SHA:0:6} -f ./client/Dockerfile ./client
                    docker build -t estonezzz/multi-server:latest -t estonezzz/multi-server:${SHA:0:6} -f ./server/Dockerfile ./server
                    docker build -t estonezzz/multi-worker:latest -t estonezzz/multi-worker:${SHA:0:6} -f ./worker/Dockerfile ./worker
                '''
            }
        }
        stage('Push') {
            
                steps {
                    def retryAttempt = 0
                    retry(2) {
                        if (retryAttempt > 0) {
                        sleep(1000 * 2 + 2000 * retryAttempt)
                }
                    retryAttempt = retryAttempt + 1
                    sh '''
                        echo "$DOCKERHUB_CREDENTIALS_PSW" | docker login -u "$DOCKERHUB_CREDENTIALS_USR" --password-stdin
                        docker push estonezzz/multi-client:latest
                        docker push estonezzz/multi-server:latest
                        docker push estonezzz/multi-worker:latest
                        docker push estonezzz/multi-client:${SHA:0:6}
                        docker push estonezzz/multi-server:${SHA:0:6}
                        docker push estonezzz/multi-worker:${SHA:0:6}
                    '''
                    }
                }
            
        }
        stage('Deploy-to-GKE') {
            steps {
                step([
                $class: 'KubernetesEngineBuilder',
                projectId: env.PROJECT_ID,
                clusterName: env.CLUSTER_NAME,
                location: env.LOCATION,
                manifestPattern: 'k8s/*.yml',
                credentialsId: env.CREDENTIALS_ID,
                verifyDeployments: true])
   
            }
        }
    }

}