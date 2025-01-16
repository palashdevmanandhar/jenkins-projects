pipeline {
    agent any
    environment {
        SERVER_DEV = "3.95.9.109"
        SERVER_PROD = "34.201.63.141"
        IMAGE_NAME = "react-app"
        CONTAINER_PORT = "80"
        HOST_PORT = "80"
        SSH_CREDS = credentials('jenkins-ssh-key')
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
                    sshagent(['jenkins-ssh-key']) {
                        sh """
                            ssh -o StrictHostKeyChecking=no ec2-user@${env.SERVER_DEV} '
                                # Get container IDs for the specific image name
                                CONTAINER_IDS=\$(docker ps -a --filter name=${env.IMAGE_NAME} --format "{{.ID}}")
                                if [ ! -z "\$CONTAINER_IDS" ]; then
                                    docker stop \$CONTAINER_IDS
                                    docker rm \$CONTAINER_IDS
                                fi
                            '
                        """
                        
                        sh """
                            docker save ${env.IMAGE_TAG} > ${env.IMAGE_NAME}-${env.BUILD_NUMBER}.tar
                            scp ${env.IMAGE_NAME}-${env.BUILD_NUMBER}.tar ec2-user@${env.SERVER_DEV}:/tmp/
                            ssh ec2-user@${env.SERVER_DEV} '
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
        stage('Deploy Production') {
            steps {
                input 'Does the development environment look OK?'
                milestone(1)
                script {
                    sshagent(['jenkins-ssh-key']) {
                        // Stop and remove existing container if it exists
                        sh """
                            ssh -o StrictHostKeyChecking=no ec2-user@${env.SERVER_PROD} '
                                CONTAINER_IDS=\$(docker ps -a --filter name=${env.IMAGE_NAME} --format "{{.ID}}")
                                if [ ! -z "\$CONTAINER_IDS" ]; then
                                    docker stop \$CONTAINER_IDS
                                    docker rm \$CONTAINER_IDS
                                fi
                            '
                        """
                        
                        // Transfer and deploy new container
                        sh """
                            scp ${env.IMAGE_NAME}-${env.BUILD_NUMBER}.tar ec2-user@${env.SERVER_PROD}:/tmp/
                            ssh ec2-user@${env.SERVER_PROD} '
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
    }
    post {
        always {
            cleanWs()
        }
        failure {
            script {
                echo "Pipeline failed! Consider adding email/Slack notifications here"
            }
        }
    }
}