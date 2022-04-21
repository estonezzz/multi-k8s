pipeline {
    agent any
    environment {
        DOCKERHUB_CREDENTIALS=credentials('docker-hub-credentials')
        CLOUDSDK_CORE_DISABLE_PROMPTS=1
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
                    echo "This is git commit ${env.GIT_COMMIT}" 
                    docker build -t estonezzz/multi-client:latest -t estonezzz/multi-client:${env.GIT_COMMIT} -f ./client/Dockerfile ./client
                    docker build -t estonezzz/multi-server:latest -t estonezzz/multi-server:${env.GIT_COMMIT} -f ./server/Dockerfile ./server
                    docker build -t estonezzz/multi-worker:latest -t estonezzz/multi-worker:${env.GIT_COMMIT} -f ./worker/Dockerfile ./worker
                '''
            }
        }
        stage('Push') {
            steps {
                sh '''
                    echo "$DOCKERHUB_CREDENTIALS_PSW" | docker login -u "$DOCKERHUB_CREDENTIALS_USR" --password-stdin
                    docker push estonezzz/multi-client:latest
                    docker push estonezzz/multi-server:latest
                    docker push estonezzz/multi-worker:latest
                    docker push estonezzz/multi-client:${env.GIT_COMMIT}
                    docker push estonezzz/multi-server:${env.GIT_COMMIT}
                    docker push estonezzz/multi-worker:${env.GIT_COMMIT}
                '''
            }
        }
    }

}