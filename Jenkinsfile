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

        stage('Frontend Build') {
            environment { REACT_APP_API_BASE_URL = 'DOMAIN_TOKEN' }
            steps {
                dir('frontend/frontend') {
                    sh 'npm install'
                    sh 'npm run build'
                }
            } 
        }

        stage('Docker, frontend image build') {
            steps {
                dir('frontend') {
                    script {
                        sh 'cp -r frontend/build ./build'
                    }
                }
                withCredentials([usernamePassword(
                        credentialsId: 'DOCKERHUB_CREDENTIALS', 
                        usernameVariable: 'DOCKERHUB_USERNAME', 
                        passwordVariable: 'DOCKERHUB_PASSWORD'
                )]) {
                    dir('frontend') {
                        sh 'echo "$DOCKERHUB_PASSWORD" | docker login -u "$DOCKERHUB_USERNAME" --password-stdin'
                        sh "docker build --no-cache -t $DOCKERHUB_USERNAME/$FRONTEND_IMAGE_NAME:$IMAGE_TAG ."
                        sh "docker push $DOCKERHUB_USERNAME/$FRONTEND_IMAGE_NAME:$IMAGE_TAG"
                    }
                }
            }
        }

        stage('Build Backend') {
            steps {
                dir('backend') {
                    dir('backend'){
                        sh 'gradle clean build -x test'
                        sh 'ls -l build/libs'
                    }
                }
            }
        }

        stage('Backend Tests') {
            steps {
                dir('backend') {
                    dir('backend') {
                        sh 'gradle test'
                    }
                }
            }
        }

        // stage('Sonar Scanning') {
        //     steps {
        //         withSonarQubeEnv('SonarQube') {
        //             sh 'sonar-scanner -Dproject.settings=./sonar/backend-sonar.properties'
        //         }
        //     }
        // }

        stage('Backend image build') {
            steps {
                script {
                    sh '''
                        rm -rf backend/ROOT
                        mkdir -p backend/ROOT
                        unzip -q backend/backend/build/libs/*.war -d backend/ROOT
                        ls -l backend/ROOT/WEB-INF/classes/
                    '''
                    withCredentials([usernamePassword(
                        credentialsId: 'DOCKERHUB_CREDENTIALS',
                        usernameVariable: 'DOCKERHUB_USERNAME',
                        passwordVariable: 'DOCKERHUB_PASSWORD'
                    )]) {
                        sh """
                            echo "$DOCKERHUB_PASSWORD" | docker login -u "$DOCKERHUB_USERNAME" --password-stdin
                            docker build -t $DOCKERHUB_USERNAME/$BACKEND_IMAGE_NAME:$IMAGE_TAG ./backend
                            docker push $DOCKERHUB_USERNAME/$BACKEND_IMAGE_NAME:$IMAGE_TAG
                        """
                    }
                }
            }
        }

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

        stage('Setup K3S') {
            steps {
                dir('ansible') {
                    sh '''
                        ansible-playbook -i ${INVENTORY} playbooks/k3s_setup.yml
                    '''
                }
            }
        }

        stage('Setup Helm') {
            steps {
                dir('ansible') {
                    sh '''
                        ansible-playbook -i ${INVENTORY} playbooks/setup_helm.yml
                    '''
                }
            }
        }

        stage('Setup Secrets') {
            steps {
                withCredentials([
                    string(credentialsId: 'K8S_NAMESPACE', variable: 'K8S_NAMESPACE'),
                    string(credentialsId: 'DOCKERHUB_USERNAME', variable: 'DOCKER_USER'),
                    string(credentialsId: 'DOCKERHUB_PASSWORD', variable: 'DOCKER_PASS'),
                    string(credentialsId: 'DOCKERHUB_EMAIL', variable: 'DOCKER_EMAIL'),
                    file(credentialsId: 'CERT', variable: 'TLS_CRT'),
                    file(credentialsId: 'KEY', variable: 'TLS_KEY')
                ]) {
                    dir('ansible') {
                       sh """
                        ansible-playbook -i inventory.ini playbooks/setup_secrets.yml \
                          -e namespace=${K8S_NAMESPACE} \
                          -e docker_user=${DOCKER_USER} \
                          -e docker_pass=${DOCKER_PASS} \
                          -e docker_email=${DOCKER_EMAIL} \
                          -e tls_crt='${TLS_CRT}' \
                          -e tls_key='${TLS_KEY}'
                        """
                    }
                }
            }
        }
        
        stage('Clone Repositories') {
            steps {
                withCredentials([
                    sshUserPrivateKey(credentialsId: 'GITHUB_SSH_KEY', keyFileVariable: 'SSH_KEY'),
                    string(credentialsId: 'GITHUB_REPO_REDIS', variable: 'GITHUB_REPO_REDIS'),
                    string(credentialsId: 'GITHUB_REPO_DATABASE', variable: 'GITHUB_REPO_DATABASE'),
                    string(credentialsId: 'GITHUB_REPO_FRONTEND', variable: 'GITHUB_REPO_FRONTEND'),
                    string(credentialsId: 'GITHUB_REPO_BACKEND', variable: 'GITHUB_REPO_BACKEND')
                ]) {
                    dir('ansible') {
                        sh """
                            ansible-playbook -i inventory.ini playbooks/clone_repos.yml \
                              -e github_repo_backend=${GITHUB_REPO_BACKEND} \
                              -e github_repo_frontend=${GITHUB_REPO_FRONTEND} \
                              -e github_repo_redis=${GITHUB_REPO_REDIS} \
                              -e github_repo_database=${GITHUB_REPO_DATABASE} \
                              -e ssh_key_path=${SSH_KEY}
                        """
                    }
                }
            }
        }

        stage('Update values & put restore file') {
            steps {
                withCredentials([
                    file(credentialsId: 'VALUES_FILE', variable: 'VALUES_FILE'),
                    file(credentialsId: 'RESTORE_DUMP', variable: 'DB_DUMP_FILE')
                ]) {
                    dir('ansible') {
                        sh '''
                            cp -f $VALUES_FILE /tmp/values.yaml
                            chmod 666 /tmp/values.yaml

                            ansible-playbook playbooks/update_values.yml \
                                -i ${INVENTORY} \
                                -e @/tmp/values.yaml \
                                -e db_dump_path=$DB_DUMP_FILE
                        '''
                    }
                }
            }
        }

        stage('Deploy App with Helm') {
            steps {
                dir('ansible') {
                    withCredentials([string(credentialsId: 'K8S_NAMESPACE', variable: 'K8S_NAMESPACE')]) {
                        sh '''
                            ansible-playbook playbooks/deploy_app.yml \
                              -i ${INVENTORY} \
                              -e "namespace=${K8S_NAMESPACE}"
                        '''
                    }
                }
            }
        }

        stage('Deploy Datadog') {
            steps {
                withCredentials([
                    string(credentialsId: 'DATADOG_API_KEY', variable: 'DD_API_KEY'),
                    string(credentialsId: 'K8S_NAMESPACE', variable: 'K8S_NAMESPACE')
                ]) {
                    dir('ansible') {
                        sh """
                        ansible-playbook -i inventory.ini playbooks/deploy_datadog.yml \
                          -e datadog_api_key=${DD_API_KEY} \
                          -e datadog_namespace=${K8S_NAMESPACE} \
                          -e datadog_domain=monitoring.class-schedule-app.pp.ua \
                          -e datadog_site=datadoghq.us5
                        """
                    }
                }
            }
        }
    }
}