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
                sh 'docker rm -f  $IMAGE_NAME'
            }
        }
        stage('Test') {
            steps {
                sh 'docker run -dti  --name $CONTAINER_NAME   -p 80:80  $DOCKERHUB_ID/$IMAGE_NAME:$TAG_NAME'
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
       
    }    
}
    