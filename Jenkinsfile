pipeline {
    agent {label 'Linux'}

    environment {
        GITHUB_URL="https://github.com/Andriy29k/Milestone4.git"
        BACKEND_IMAGE_NAME = 'class_schedule_backend'
        IMAGE_TAG = 'latest'
    }

    tools {
        gradle 'gradle-6.8'
        jdk 'jdk-11'
    }

    stages {
        stage('Checkout branch') {
            steps {
                git branch: 'dev',
                    url: "${env.GITHUB_URL}",
                    credentialsId: 'github-credentials'
            }
        }
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

        stage('Ansible inventory generation') {
            steps {
                dir ('ansible') {
                    sh '''
                        rm -rf inventory.ini
                    '''
                }
                dir('ansible/files') {
                    sh '''
                        chmod +x generate_inventory_from_config.sh
                        bash generate_inventory_from_config.sh
                    '''
                }
                dir('ansible') {
                    sh '''
                        ansible all -i inventory.ini -m ping
                    '''
                }
            }
        }

        stage('K3S Setup') {
            steps {
                dir('ansible') {
                    sh '''
                        ansible-playbook -i inventory.ini playbooks/install_k3s.yml -vvv
                    '''
                }
            }
        }    

        stage('Deploy Services') {
            steps {
                dir('ansible') {
                    withCredentials([
                        file(credentialsId: 'RESTORE_DUMP', variable: 'RESTORE_FILE_PATH'),
                        string(credentialsId: 'POSTGRES_USER', variable: 'POSTGRES_USER'),
                        string(credentialsId: 'POSTGRES_PASSWORD', variable: 'POSTGRES_PASSWORD'),
                        string(credentialsId: 'POSTGRES_DB', variable: 'POSTGRES_DB'),
                        string(credentialsId: 'REDIS_IMAGE', variable: 'REDIS_IMAGE'),
                        string(credentialsId: 'BACKEND_IMAGE', variable: 'BACKEND_IMAGE'),
                        string(credentialsId: 'FRONTEND_IMAGE', variable: 'FRONTEND_IMAGE'),
                        string(credentialsId: 'DOCKERHUB_USERNAME', variable: 'DOCKERHUB_USERNAME'),
                        string(credentialsId: 'DOCKERHUB_PASSWORD', variable: 'DOCKERHUB_PASSWORD'),
                        string(credentialsId: 'DOCKERHUB_EMAIL', variable: 'DOCKERHUB_EMAIL')
                    ]) {
                        sh '''
                            mkdir -p roles/postgres/files
                            cat $RESTORE_FILE_PATH > roles/postgres/files/restore.sql
                            ansible-playbook -i inventory.ini playbooks/deploy_postgres.yml
                            ansible-playbook -i inventory.ini playbooks/deploy_redis.yml
                            ansible-playbook -i inventory.ini playbooks/deploy_backend.yml
                            ansible-playbook -i inventory.ini playbooks/deploy_frontend.yml
                            ansible-playbook -i inventory.ini playbooks/deploy_ingress.yml
                        '''
                    }
                }
            }
        }
    }
}