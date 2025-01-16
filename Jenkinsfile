pipeline {
    agent any
    environment {
        SERVER_DEV = "ec2-user@54.83.74.235"
        SERVER_PROD = "ec2-user@34.228.82.30"
        IMAGE_NAME = "react-app"
        CONTAINER_PORT = "80"
        HOST_PORT =  "80"
    }
    stages {
        stage('Initialize') {
            steps {
                script {
                    env.IMAGE_TAG = "${IMAGE_NAME}:${env.BUILD_NUMBER}"
                    env.CONTAINER_NAME = "${IMAGE_NAME}-${env.BUILD_NUMBER}"
                    echo "Using Docker image tag: ${env.IMAGE_TAG}"
                }
            }
        }
        stage('Checkout') {
            steps {
                echo "Checking out the code"
                checkout scm
            }
        }
        stage('Build Docker Image') {
            steps {
                echo "Building Docker image"
                script {
                    sh "docker build -t ${env.IMAGE_TAG} --build-arg BUILD_NUMBER=${env.BUILD_NUMBER} ."
                }
            }
        }
        stage('Deploy Development') {
            steps {
                script {
                    // Stop and remove existing container if it exists
                    sh """
                        ssh ${env.SERVER_DEV} '
                            if docker ps -a | grep -q ${env.IMAGE_NAME}; then
                                docker stop \$(docker ps -a | grep ${env.IMAGE_NAME} | awk "{print \$1}")
                                docker rm \$(docker ps -a | grep ${env.IMAGE_NAME} | awk "{print \$1}")
                            fi
                        '
                    """
                    
                    // Transfer and deploy new container
                    sh """
                        docker save ${env.IMAGE_TAG} > ${env.IMAGE_NAME}-${env.BUILD_NUMBER}.tar
                        scp ${env.IMAGE_NAME}-${env.BUILD_NUMBER}.tar ${env.SERVER_DEV}:/tmp/
                        ssh ${env.SERVER_DEV} '
                            docker load < /tmp/${env.IMAGE_NAME}-${env.BUILD_NUMBER}.tar && \
                            docker run -d \
                                --name ${env.CONTAINER_NAME} \
                                -p ${env.HOST_PORT}:${env.CONTAINER_PORT} \
                                --restart unless-stopped \
                                ${env.IMAGE_TAG}
                            rm /tmp/${env.IMAGE_NAME}-${env.BUILD_NUMBER}.tar
                        '
                    """
                }
            }
        }
        stage('Deploy Production') {
            steps {
                input 'Does the development environment look OK?'
                milestone(1)
                script {
                    // Stop and remove existing container if it exists
                    sh """
                        ssh ${env.SERVER_PROD} '
                            if docker ps -a | grep -q ${env.IMAGE_NAME}; then
                                docker stop \$(docker ps -a | grep ${env.IMAGE_NAME} | awk "{print \$1}")
                                docker rm \$(docker ps -a | grep ${env.IMAGE_NAME} | awk "{print \$1}")
                            fi
                        '
                    """
                    
                    // Transfer and deploy new container
                    sh """
                        scp ${env.IMAGE_NAME}-${env.BUILD_NUMBER}.tar ${env.SERVER_PROD}:/tmp/
                        ssh ${env.SERVER_PROD} '
                            docker load < /tmp/${env.IMAGE_NAME}-${env.BUILD_NUMBER}.tar && \
                            docker run -d \
                                --name ${env.CONTAINER_NAME} \
                                -p ${env.HOST_PORT}:${env.CONTAINER_PORT} \
                                --restart unless-stopped \
                                ${env.IMAGE_TAG}
                            rm /tmp/${env.IMAGE_NAME}-${env.BUILD_NUMBER}.tar
                        '
                    """
                }       
            }
        }
    }
    post {
        always {
            cleanWs()
        }
        failure {
            script {
                // Send notification on failure
                echo "Pipeline failed! Consider adding email/Slack notifications here"
            }
        }
    }
}
