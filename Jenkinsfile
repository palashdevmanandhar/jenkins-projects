def getEC2PublicIPs(String tagName= null,String tagValue= null) {
    // Original getEC2PublicIPs function remains the same
    withAWS(region: 'us-east-1', credentials: 'aws-credentials') {
        def filterCommand

        if (tagName && tagValue) {
            filterCommand = """
            aws ec2 describe-instances \
            --query 'Reservations[*].Instances[*].PublicIpAddress' \
            --output text \
            --filters "Name=instance-state-name,Values=running" "Name=tag:${tagName},Values=${tagValue}"
        """
        }else{
            filterCommand = '''
            aws ec2 describe-instances \
            --query 'Reservations[*].Instances[*].PublicIpAddress' \
            --output text \
            --filters "Name=instance-state-name,Values=running"
        '''
        }
        
        def output = sh(
            script: filterCommand,
            returnStdout: true
        ).trim()
        
        def instances = []
        if (output) {
            instances = output.split('\n')
        }
        
        return instances
    }
}

def cleanupRemoteServer(String server) {
    // Function to clean up space on remote server
    sshagent(['jenkins-ssh-key']) {
        sh """
            ssh -o StrictHostKeyChecking=no ec2-user@${server} '
                # Remove old Docker images and containers
                docker system prune -af --volumes
                
                # Clean /tmp directory of old tar files
                find /tmp -name "*.tar" -type f -mtime +1 -delete
                
                # Check available space
                df -h /tmp
            '
        """
    }
}

pipeline {
    agent any
    environment {
        IMAGE_NAME = "react-app"
        CONTAINER_PORT = "80"
        HOST_PORT = "80"
        SSH_CREDS = credentials('jenkins-ssh-key')
        DEPLOY_DIR = "/opt/deployments"  // New deployment directory
    }
    stages {
        // Previous stages remain the same until Deploy Development
        
        stage('Deploy Development') {
            steps {
                script {
                    sshagent(['jenkins-ssh-key']) {
                        // Create deployment directory if it doesn't exist
                        sh """
                            ssh -o StrictHostKeyChecking=no ec2-user@${env.SERVER_DEV} '
                                sudo mkdir -p ${env.DEPLOY_DIR}
                                sudo chown ec2-user:ec2-user ${env.DEPLOY_DIR}
                            '
                        """
                        
                        // Clean up before deployment
                        cleanupRemoteServer(env.SERVER_DEV)
                        
                        // Stop and remove existing containers
                        sh """
                            ssh -o StrictHostKeyChecking=no ec2-user@${env.SERVER_DEV} '
                                CONTAINER_IDS=\$(docker ps -a --filter name=${env.IMAGE_NAME} --format "{{.ID}}")
                                if [ ! -z "\$CONTAINER_IDS" ]; then
                                    docker stop \$CONTAINER_IDS
                                    docker rm \$CONTAINER_IDS
                                fi
                            '
                        """
                        
                        // Transfer and deploy new container
                        sh """
                            docker save ${env.IMAGE_TAG} > ${env.IMAGE_NAME}-${env.BUILD_NUMBER}.tar
                            scp ${env.IMAGE_NAME}-${env.BUILD_NUMBER}.tar ec2-user@${env.SERVER_DEV}:${env.DEPLOY_DIR}/
                            ssh ec2-user@${env.SERVER_DEV} '
                                docker load < ${env.DEPLOY_DIR}/${env.IMAGE_NAME}-${env.BUILD_NUMBER}.tar && \
                                docker run -d \
                                    --name ${env.CONTAINER_NAME} \
                                    -p ${env.HOST_PORT}:${env.CONTAINER_PORT} \
                                    --restart unless-stopped \
                                    ${env.IMAGE_TAG}
                                rm ${env.DEPLOY_DIR}/${env.IMAGE_NAME}-${env.BUILD_NUMBER}.tar
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
                    def prodServerList = env.SERVER_PROD.split(',')
                    
                    prodServerList.each { serverIP ->
                        echo "Deploying to production server: ${serverIP}"
                        sshagent(['jenkins-ssh-key']) {
                            // Create deployment directory
                            sh """
                                ssh -o StrictHostKeyChecking=no ec2-user@${serverIP} '
                                    sudo mkdir -p ${env.DEPLOY_DIR}
                                    sudo chown ec2-user:ec2-user ${env.DEPLOY_DIR}
                                '
                            """
                            
                            // Clean up before deployment
                            cleanupRemoteServer(serverIP)
                            
                            // Stop and remove existing containers
                            sh """
                                ssh -o StrictHostKeyChecking=no ec2-user@${serverIP} '
                                    CONTAINER_IDS=\$(docker ps -a --filter name=${env.IMAGE_NAME} --format "{{.ID}}")
                                    if [ ! -z "\$CONTAINER_IDS" ]; then
                                        docker stop \$CONTAINER_IDS
                                        docker rm \$CONTAINER_IDS
                                    fi
                                '
                            """
                            
                            // Transfer and deploy new container
                            sh """
                                scp ${env.IMAGE_NAME}-${env.BUILD_NUMBER}.tar ec2-user@${serverIP}:${env.DEPLOY_DIR}/
                                ssh ec2-user@${serverIP} '
                                    docker load < ${env.DEPLOY_DIR}/${env.IMAGE_NAME}-${env.BUILD_NUMBER}.tar && \
                                    docker run -d \
                                        --name ${env.CONTAINER_NAME} \
                                        -p ${env.HOST_PORT}:${env.CONTAINER_PORT} \
                                        --restart unless-stopped \
                                        ${env.IMAGE_TAG}
                                    rm ${env.DEPLOY_DIR}/${env.IMAGE_NAME}-${env.BUILD_NUMBER}.tar
                                '
                            """
                        }
                    }
                }   
            }    
        }
    }
    
    post {
        always {
            cleanWs()
            script {
                // Clean up local Docker image
                sh "rm -f ${env.IMAGE_NAME}-${env.BUILD_NUMBER}.tar || true"
            }
        }
        failure {
            script {
                echo "Pipeline failed! Consider adding email/Slack notifications here"
            }
        }
    }
}