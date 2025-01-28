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
        DEPLOY_DIR = "/opt/deployments"
        AWS_REGION = "us-east-1"
        ECR_REPOSITORY = "react-jenkins-project-repo"
    }
    stages {
        // Previous stages remain the same until Deploy Development

        stage('Get IPs') {
            steps {
                script {
                    
                        try {
                            echo "Getting EC2 IPs for environment: prod"
                            def devIps = getEC2PublicIPs('env','dev')
                            env.SERVER_DEV = "${devIps[0]}"
                            echo "Dev IPs: ${devIps[0]}"
                            def prodIps = getEC2PublicIPs('env','prod')
                            echo "Prod IPs: ${prodIps}"
                            env.SERVER_PROD = prodIps.join(',') 
                        } catch (Exception e) {
                            echo "Error getting IPs: ${e.message}"
                            error("Failed to get EC2 IPs")
                        }
                    
                }
            }
        }
        stage('Initialize') {
            steps {
                script {
                    withAWS(region: "${AWS_REGION}", credentials: 'aws-credentials') {
                        // Get AWS Account ID
                        env.AWS_ACCOUNT_ID = sh(
                            script: 'aws sts get-caller-identity --query "Account" --output text',
                            returnStdout: true
                        ).trim()
                        
                        // Set ECR registry after getting account ID
                        env.ECR_REGISTRY = "${env.AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com"
                        
                        echo "Retrieved AWS Account ID: ${env.AWS_ACCOUNT_ID}"
                        echo "ECR Registry: ${env.ECR_REGISTRY}"
                    }
                    env.IMAGE_TAG = "${env.BUILD_NUMBER}"
                    env.FULL_IMAGE_NAME = "${ECR_REGISTRY}/${ECR_REPOSITORY}:${env.IMAGE_TAG}"
                    env.CONTAINER_NAME = "${IMAGE_NAME}-${env.BUILD_NUMBER}"
                    echo "Using Docker image: ${env.FULL_IMAGE_NAME}"
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
                    sh "docker build -t ${env.FULL_IMAGE_NAME} --build-arg BUILD_NUMBER=${env.BUILD_NUMBER} ."
                }
            }
        }

        stage('Push to ECR') {
            steps {
                script {
                    withAWS(region: "${AWS_REGION}", credentials: 'aws-credentials') {
                        sh """
                            aws ecr get-login-password --region ${AWS_REGION} | docker login --username AWS --password-stdin ${ECR_REGISTRY}
                            docker push ${env.FULL_IMAGE_NAME}
                        """
                    }
                }
            }
        }
        
         stage('Deploy Development') {
            steps {
                script {
                    sshagent(['jenkins-ssh-key']) {
                        // Stop and remove existing containers
                        sh """
                            ssh -o StrictHostKeyChecking=no ec2-user@${env.SERVER_DEV} '

                                # First authenticate with ECR
                                aws ecr get-login-password --region ${AWS_REGION} | docker login --username AWS --password-stdin ${ECR_REGISTRY}

                                CONTAINER_IDS=\$(docker ps -a --filter name=${env.IMAGE_NAME} --format "{{.ID}}")
                                if [ ! -z "\$CONTAINER_IDS" ]; then
                                    docker stop \$CONTAINER_IDS
                                    docker rm \$CONTAINER_IDS
                                fi
                                
                                # Pull latest image from ECR
                                docker pull ${env.FULL_IMAGE_NAME}
                                
                                # Run new container
                                docker run -d \
                                    --name ${env.CONTAINER_NAME} \
                                    -p ${env.HOST_PORT}:${env.CONTAINER_PORT} \
                                    --restart unless-stopped \
                                    ${env.FULL_IMAGE_NAME}
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
                            // Clean up before deployment
                            cleanupRemoteServer(serverIP)
                            
                            // Deploy using image from ECR
                            sh """
                                ssh -o StrictHostKeyChecking=no ec2-user@${serverIP} '
                                    # First authenticate with ECR
                                    aws ecr get-login-password --region ${AWS_REGION} | docker login --username AWS --password-stdin ${ECR_REGISTRY}
                                    
                                    CONTAINER_IDS=\$(docker ps -a --filter name=${env.IMAGE_NAME} --format "{{.ID}}")
                                    if [ ! -z "\$CONTAINER_IDS" ]; then
                                        docker stop \$CONTAINER_IDS
                                        docker rm \$CONTAINER_IDS
                                    fi
                                    
                                    # Pull latest image from ECR
                                    docker pull ${env.FULL_IMAGE_NAME}
                                    
                                    # Run new container
                                    docker run -d \
                                        --name ${env.CONTAINER_NAME} \
                                        -p ${env.HOST_PORT}:${env.CONTAINER_PORT} \
                                        --restart unless-stopped \
                                        ${env.FULL_IMAGE_NAME}
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