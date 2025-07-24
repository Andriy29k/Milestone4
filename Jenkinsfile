pipeline {
    agent {label 'Linux'}

    environment {
        GITHUB_URL="https://github.com/Andriy29k/Milestone4.git"
        BACKEND_IMAGE_NAME = 'class_schedule_backend'
        FRONTEND_IMAGE_NAME = 'class_schedule_frontend'
        IMAGE_TAG = 'latest'
        ANSIBLE_CONFIG = "${WORKSPACE}/ansible/ansible.cfg"
        INVENTORY = "${WORKSPACE}/ansible/inventory.ini"
    }

    tools {
        gradle 'gradle-6.8'
        jdk 'jdk-11'
        nodejs 'nodejs-18'
    }

    stages {
        stage('Checkout branch') {
            steps {
                git branch: 'dev',
                    url: "${env.GITHUB_URL}",
                    credentialsId: 'github-credentials'
            }
        }

        // stage('Frontend Build') {
        //     environment { REACT_APP_API_BASE_URL = 'DOMAIN_TOKEN' }
        //     steps {
        //         dir('frontend/frontend') {
        //             sh 'npm install'
        //             sh 'npm run build'
        //         }
        //     } 
        // }

        // stage('Docker, frontend image build') {
        //     steps {
        //         dir('frontend') {
        //             script {
        //                 sh 'cp -r frontend/build ./build'
        //             }
        //         }
        //         withCredentials([usernamePassword(
        //                 credentialsId: 'DOCKERHUB_CREDENTIALS', 
        //                 usernameVariable: 'DOCKERHUB_USERNAME', 
        //                 passwordVariable: 'DOCKERHUB_PASSWORD'
        //         )]) {
        //             dir('frontend') {
        //                 sh 'echo "$DOCKERHUB_PASSWORD" | docker login -u "$DOCKERHUB_USERNAME" --password-stdin'
        //                 sh "docker build --no-cache -t $DOCKERHUB_USERNAME/$FRONTEND_IMAGE_NAME:$IMAGE_TAG ."
        //                 sh "docker push $DOCKERHUB_USERNAME/$FRONTEND_IMAGE_NAME:$IMAGE_TAG"
        //             }
        //         }
        //     }
        // }
        // stage('Build Backend') {
        //     steps {
        //         dir('backend') {
        //             dir('backend'){
        //                 sh 'gradle clean build -x test'
        //                 sh 'ls -l build/libs'
        //             }
        //         }
        //     }
        // }

        // stage('Backend Tests') {
        //     steps {
        //         dir('backend') {
        //             dir('backend') {
        //                 sh 'gradle test'
        //             }
        //         }
        //     }
        // }

        // stage('Sonar Scanning') {
        //     steps {
        //         withSonarQubeEnv('SonarQube') {
        //             sh 'sonar-scanner -Dproject.settings=./sonar/backend-sonar.properties'
        //         }
        //     }
        // }

        // stage('Backend image build') {
        //     steps {
        //         script {
        //             sh '''
        //                 rm -rf backend/ROOT
        //                 mkdir -p backend/ROOT
        //                 unzip -q backend/backend/build/libs/*.war -d backend/ROOT
        //                 ls -l backend/ROOT/WEB-INF/classes/
        //             '''
        //             withCredentials([usernamePassword(
        //                 credentialsId: 'DOCKERHUB_CREDENTIALS',
        //                 usernameVariable: 'DOCKERHUB_USERNAME',
        //                 passwordVariable: 'DOCKERHUB_PASSWORD'
        //             )]) {
        //                 sh """
        //                     echo "$DOCKERHUB_PASSWORD" | docker login -u "$DOCKERHUB_USERNAME" --password-stdin
        //                     docker build -t $DOCKERHUB_USERNAME/$BACKEND_IMAGE_NAME:$IMAGE_TAG ./backend
        //                     docker push $DOCKERHUB_USERNAME/$BACKEND_IMAGE_NAME:$IMAGE_TAG
        //                 """
        //             }
        //         }
        //     }
        // }

        stage('Generate Inventory') {
            steps {
                sh '''
                cd terraform/scripts
                chmod +x generate_inventory.sh
                ./generate_inventory.sh
                '''
                sh 'cat ${INVENTORY}'
            }
        }

        stage('Ansible inventory generation') {
            steps {
                dir('ansible') {
                    sh 'ansible all -i ${INVENTORY} -m ping' 
                }
            }
        }

        // stage('Setup K3S') {
        //     steps {
        //         dir('ansible') {
        //             sh '''
        //                 ansible-playbook -i ${INVENTORY} playbooks/setup_k3s.yml
        //             '''
        //         }
        //     }
        // }

        // stage('Setup Helm') {
        //     steps {
        //         dir('ansible') {
        //             sh '''
        //                 ansible-playbook -i ${INVENTORY} playbooks/setup_helm.yml
        //             '''
        //         }
        //     }
        // }

        stage('Setup Secrets') {
            steps {
                withCredentials([
                    string(credentialsId: 'K8S-NAMESPACE', variable: 'K8S_NAMESPACE'),
                    usernamePassword(credentialsId: 'DOCKERHUB_CREDENTIALS', usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS'),
                    string(credentialsId: 'DOCKER-EMAIL', variable: 'DOCKER_EMAIL'),
                    file(credentialsId: 'CERT', variable: 'TLS_CRT'),
                    file(credentialsId: 'KEY', variable: 'TLS_KEY')
                ]) {
                    sh '''
                        ansible-playbook -i ansible/inventory.ini ansible/playbooks/setup_secrets.yml \
                          --extra-vars "namespace=$K8S_NAMESPACE docker_user=$DOCKER_USER docker_pass=$DOCKER_PASS docker_email=$DOCKER_EMAIL tls_crt=$TLS_CRT tls_key=$TLS_KEY"
                    '''
                }
            }
        }
    }
}