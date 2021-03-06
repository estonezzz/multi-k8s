pipeline {
    agent any
    environment {
        DOCKERHUB_CREDENTIALS=credentials('docker-hub-credentials')
        CLOUDSDK_CORE_DISABLE_PROMPTS=1
        SHA=sh(script: 'git rev-parse HEAD | cut -c 1-6', returnStdout: true).trim()
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
                    docker build -t estonezzz/multi-client:latest -t estonezzz/multi-client:$SHA -f ./client/Dockerfile ./client
                    docker build -t estonezzz/multi-server:latest -t estonezzz/multi-server:$SHA -f ./server/Dockerfile ./server
                    docker build -t estonezzz/multi-worker:latest -t estonezzz/multi-worker:$SHA -f ./worker/Dockerfile ./worker
                '''
            }
        }
        stage('Push') {
            
                steps {
                    retry(3) {
                    sh '''
                        echo "$DOCKERHUB_CREDENTIALS_PSW" | docker login -u "$DOCKERHUB_CREDENTIALS_USR" --password-stdin
                        docker push estonezzz/multi-client:latest
                        docker push estonezzz/multi-server:latest
                        docker push estonezzz/multi-worker:latest
                        docker push estonezzz/multi-client:$SHA
                        docker push estonezzz/multi-server:$SHA
                        docker push estonezzz/multi-worker:$SHA
                    '''
                    }
                }          
            
        }
         stage ('AKS Deploy') {
        steps {
            sh '''
                        find k8s/*.yml | xargs -I{} sh -c "cat {}; echo '\n---\n'" > deploy_AKS.yml
                        sed -i '1h;1!H;$!d;g;s/\\(.*\\)---/\\1/' deploy_AKS.yml
                        sed -i 's/:latest/:$SHA/g' deploy_AKS.yml
                        cat deploy_AKS.yml
                '''
            script {
                kubernetesDeploy(
                    configs: 'deploy_AKS.yml',
                    kubeconfigId: 'AKS-k8s-multi',
                    enableConfigSubstitution: true
                    )           
               
            }
        }
    }
    }

}