pipeline {
    agent any

    environment {
        IMAGE_NAME="ic-webapp"
        CONTAINER_NAME="test-ic-webapp"
        TAG_NAME="v1.0"
        DOCKERHUB_ID="ada2019"
        DOCKERHUB_PASSWORD=credentials('DOCKERHUB_PW')
        SSH_PRIVATE_KEY=credentials('aws_key_paire')

    }

    stages {
        stage('Build') {
            
            steps {
                sh 'docker build -t  $DOCKERHUB_ID/$IMAGE_NAME:$TAG_NAME .'
                sh 'docker rm -f  $CONTAINER_NAME'
            }
        }
        stage('Test') {
            steps {
                sh 'docker run -dti  --name $CONTAINER_NAME   -p 8000:8000  $DOCKERHUB_ID/$IMAGE_NAME:$TAG_NAME'
                sh 'sleep 5'
                sh 'curl -I http://172.17.0.1'
        
            }
        }
        stage('clear container') {
            steps {
                sh '''
                 docker stop $CONTAINER_NAME
                 docker rm $CONTAINER_NAME
                '''       
            }
        }
        stage('Release') {
            steps {
                sh '''
                echo $DOCKERHUB_PASSWORD | docker login -u $DOCKERHUB_ID --password-stdin
                docker push  $DOCKERHUB_ID/$IMAGE_NAME:$TAG_NAME
                '''
            }
        }
        stage('deploy staging and test') {          
            steps {
              withCredentials([aws(accessKeyVariable: 'AWS_ACCESS_KEY_ID', credentialsId: 'aws_access', secretKeyVariable: 'AWS_SECRET_ACCESS_KEY')]) {
                dir('staging') {
                sh '''
                terraform init \
                  -var-file="env_staging.tfvars" \
                  -var  ssh_key_file="${SSH_PRIVATE_KEY}"
                terraform plan \
                  -var-file="env_staging.tfvars" \
                  -var  ssh_key_file="${SSH_PRIVATE_KEY}"
                terraform apply -auto-approve \
                  -var-file="env_staging.tfvars" \
                  -var  ssh_key_file="${SSH_PRIVATE_KEY}"
                export STAGING_SERVER=$(awk '/PUBLIC_IP/ {sub(/^.* *PUBLIC_IP/,""); print $2}' infos_ec2.txt)
                '''
                }
              }
            }
        }
        stage('destroy staging') {          
            steps {
              withCredentials([aws(accessKeyVariable: 'AWS_ACCESS_KEY_ID', credentialsId: 'aws_access', secretKeyVariable: 'AWS_SECRET_ACCESS_KEY')]) {
                dir('staging') {
                sh '''
                terraform destroy -auto-approve \
                  -var-file="env_staging.tfvars" \
                  -var  ssh_key_file="${SSH_PRIVATE_KEY}"
                '''
                }
              }
            }
        }
        stage('deploy prod and test') {
           
            steps {
              withCredentials([aws(accessKeyVariable: 'AWS_ACCESS_KEY_ID', credentialsId: 'aws_access', secretKeyVariable: 'AWS_SECRET_ACCESS_KEY')]) {
                dir ('prod') {
                sh '''
                terraform init \
                  -var-file="env_prod.tfvars" \
                  -var  ssh_key_file="${SSH_PRIVATE_KEY}"
                terraform plan \
                  -var-file="env_prod.tfvars" \
                  -var  ssh_key_file="${SSH_PRIVATE_KEY}"
                terraform apply -auto-approve \
                  -var-file="env_prod.tfvars" \
                  -var  ssh_key_file="${SSH_PRIVATE_KEY}"
                export PROD_SERVER=$(awk '/PUBLIC_IP/ {sub(/^.* *PUBLIC_IP/,""); print $2}' infos_ec2.txt)
                '''
                }
              }
        
            }
        }    
       
    }

}
    