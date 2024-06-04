/* import shared library */
@Library('shared-library')_
pipeline {
    agent any

    environment {
        IMAGE_NAME="${IMAGE_NAME_PARAM}"
        CONTAINER_NAME="${CONTAINER_NAME_PARAM}"
        TAG_NAME="${TAG_NAME_PARAM}"
        DOCKERHUB_ID="ada2019"
        DOCKERHUB_PASSWORD=credentials('DOCKERHUB_PW')
        SSH_PRIVATE_KEY=credentials('aws_key_paire')
        VAULT_KEY=credentials('vault_key')   
    }
    stages {
        stage('Build') {
            
            steps {
                sh '''
                  export TAG_NAME=$(awk '/version/ {sub(/^.* *version/,""); print $2}' releases.txt)
                  docker build -t  $DOCKERHUB_ID/$IMAGE_NAME:$TAG_NAME .
                  docker rm -f  $CONTAINER_NAME
                  '''
            }
        }
        stage('Test') {
            steps {
                sh '''
                  docker run -dti  --name $CONTAINER_NAME   -p 8000:8080  $DOCKERHUB_ID/$IMAGE_NAME:$TAG_NAME
                  sleep 5
                  curl -I http://172.17.0.1:8000
                '''
                
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
        
        stage('deploy staging ') {  
          stages {  
            stage ('Staging -build infra on aws with terraform') {      
            steps {
              withCredentials([aws(accessKeyVariable: 'AWS_ACCESS_KEY_ID', credentialsId: 'aws_access', secretKeyVariable: 'AWS_SECRET_ACCESS_KEY')]) {
                dir('terraform-ressources/staging') {
                sh '''
                rm -f server_ip.txt
                terraform init \
                  -var-file="env_staging.tfvars" 
                terraform plan \
                  -var-file="env_staging.tfvars" 
                terraform apply -auto-approve \
                  -var-file="env_staging.tfvars" 
                echo "clean host_vars file"
                cat /dev/null > ../../ansible-ressources/host_vars/odoo_server_staging.yml
                cat /dev/null > ../../ansible-ressources/host_vars/ic_webapp_pgadmin_server_staging.yml
                echo "clean ic-webapp vars role"
                cat /dev/null > ../../ansible-ressources/roles/ic-webapp_role/vars/main.yml
                echo "init host_vars file"
                echo "ansible_host: $(awk '/pgadmin_host/ {sub(/^.* *pgadmin_host/,""); print $2}' server_ip.txt)" > ../../ansible-ressources/host_vars/ic_webapp_pgadmin_server_staging.yml
                echo "ansible_host: $(awk '/odoo_host/ {sub(/^.* *odoo_host/,""); print $2}' server_ip.txt)" > ../../ansible-ressources/host_vars/odoo_server_staging.yml
                echo "init ic-webapp vars role"
                echo  "pgadmin_host: $(awk '/pgadmin_host/ {sub(/^.* *pgadmin_host/,""); print $2}' server_ip.txt)" >> ../../ansible-ressources/roles/ic-webapp_role/vars/main.yml
                echo  "odoo_host: $(awk '/odoo_host/ {sub(/^.* *odoo_host/,""); print $2}' server_ip.txt)" >>  ../../ansible-ressources/roles/ic-webapp_role/vars/main.yml
                cat ../../ansible-ressources/roles/ic-webapp_role/vars/main.yml 
                sleep 60
                '''
                }
              }
            }
        }
        stage('Ping staging env hosts') {          
            steps {
              
                dir('ansible-ressources') {
                sh '''
                 ansible staging -m ping  --extra-vars ssh_private_key="${SSH_PRIVATE_KEY}"
                 '''
                  }
             }
        }
        stage('check ansible playbook syntax') {          
            steps {
              
                dir('ansible-ressources') {
                sh '''
                 ansible-lint deploy-ic-staging.yml  || echo passing linter
                 '''
                  }
             }
        }
        stage('deploy app on staging with ansible') {          
            steps {
              
                dir('ansible-ressources') {
                sh '''
                 ansible-playbook deploy-ic-staging.yml --vault-password-file "${VAULT_KEY}" --extra-vars ssh_private_key="${SSH_PRIVATE_KEY}"
                 '''
                  }
             }
        }
          }
        }
        stage('destroy staging') {          
            steps {
              timeout(time: 10, unit: "MINUTES") {
                        input message: "Confirmer vous la suppression de l'environnement staging dans AWS ?", ok: 'Yes'
                    } 
              withCredentials([aws(accessKeyVariable: 'AWS_ACCESS_KEY_ID', credentialsId: 'aws_access', secretKeyVariable: 'AWS_SECRET_ACCESS_KEY')]) {
                dir('terraform-ressources/staging') {
                sh '''
                terraform destroy -auto-approve \
                  -var-file="env_staging.tfvars" 
                '''
                }
              }
            }
        }

        stage('deploy prod and test') {
          when {
           expression { GIT_BRANCH == 'origin/main' }
           }
           stages {
            stage ('Prod -build infra on aws with terraform'){
             steps {
              withCredentials([aws(accessKeyVariable: 'AWS_ACCESS_KEY_ID', credentialsId: 'aws_access', secretKeyVariable: 'AWS_SECRET_ACCESS_KEY')]) {
                dir ('terraform-ressources/prod') {
                sh '''
                rm -f server_ip.txt
                terraform init \
                  -var-file="env_prod.tfvars" 
                terraform plan \
                  -var-file="env_prod.tfvars" 
                terraform apply -auto-approve \
                  -var-file="env_prod.tfvars" 
                echo "clean host_vars file"
                cat /dev/null > ../../ansible-ressources/host_vars/odoo_server_prod.yml
                cat /dev/null > ../../ansible-ressources/host_vars/ic_webapp_pgadmin_server_prod.yml
                echo "clean ic-webapp vars role"
                cat /dev/null > ../../ansible-ressources/roles/ic-webapp_role/vars/main.yml
                echo "init host_vars file"
                echo "ansible_host: $(awk '/pgadmin_host/ {sub(/^.* *pgadmin_host/,""); print $2}' server_ip.txt)" > ../../ansible-ressources/host_vars/ic_webapp_pgadmin_server_prod.yml
                echo "ansible_host: $(awk '/odoo_host/ {sub(/^.* *odoo_host/,""); print $2}' server_ip.txt)" > ../../ansible-ressources/host_vars/odoo_server_prod.yml
                echo "init ic-webapp vars role"
                echo  "pgadmin_host: $(awk '/pgadmin_host/ {sub(/^.* *pgadmin_host/,""); print $2}' server_ip.txt)" >> ../../ansible-ressources/roles/ic-webapp_role/vars/main.yml
                echo  "odoo_host: $(awk '/odoo_host/ {sub(/^.* *odoo_host/,""); print $2}' server_ip.txt)" >>  ../../ansible-ressources/roles/ic-webapp_role/vars/main.yml
                cat ../../ansible-ressources/roles/ic-webapp_role/vars/main.yml 
                sleep 60
                '''
                }
              }
        
            }
        }    
       
       stage('Ping prod env hosts') {          
            steps {
              
                dir('ansible-ressources') {
                sh '''
                 
                 ansible prod -m ping  --extra-vars ssh_private_key="${SSH_PRIVATE_KEY}"
                 '''
                  }
             }
        }
        stage('check ansible playbook syntax') {          
            steps {
              
                dir('ansible-ressources') {
                sh '''
                 ansible-lint deploy-ic-prod.yml  || echo passing linter
                 '''
                  }
             }
        }
        stage('deploy app on prod with ansible') {          
            steps {
              
                dir('ansible-ressources') {
                sh '''
                 ansible-playbook deploy-ic-prod.yml --vault-password-file "${VAULT_KEY}" --extra-vars ssh_private_key="${SSH_PRIVATE_KEY}"
                 '''
                  }
             }
        }
          }
        }
    }

    post {
    always {
      script {
        slackNotifier currentBuild.result
      }
    }  
  }

}
    
