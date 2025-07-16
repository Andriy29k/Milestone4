pipeline {
    agent { label 'Linux' }

    environment {
        GITHUB_URL = "https://github.com/Andriy29k/intern_project01.git"
    }

    tools {
        terraform 'terraform-50623'
    }

    stages {
        stage('Init') {
            steps {
                script {
                    echo "Building branch: ${env.BRANCH_NAME}"
                }
            }
        }

        stage('Deploy Infrastructure') {
            when {
                anyOf {
                    branch 'dev'
                    branch 'main'
                }
            }
            steps {
                dir('terraform') {
                    withCredentials([
                        file(credentialsId: 'TERRAFORM-TFVARS', variable: 'TFVARS_FILE'),
                        file(credentialsId: 'GCP_CREDS_JSON', variable: 'GOOGLE_CREDENTIALS')
                    ]) {
                        script {
                            sh 'terraform init'
                            sh 'terraform validate'
                            def planExitCode = sh(
                                script: """
                                    terraform plan -detailed-exitcode -var "google_credentials_file=$GOOGLE_CREDENTIALS" -var-file="$TFVARS_FILE" > tfplan.log
                                """,
                                returnStatus: true
                            )

                            if (planExitCode == 0) {
                                echo "Infrastructure is up-to-date. Skipping stage..."
                            } else if (planExitCode == 2) {
                                sh """
                                    terraform apply -auto-approve -var "google_credentials_file=$GOOGLE_CREDENTIALS" -var-file="$TFVARS_FILE"
                                """
                            } else {
                                error "Terraform plan failed"
                            }
                        }
                    }
                }
            }
        }

        stage('Destroy Infrastructure') {
            when {
                branch 'main'
                branch 'dev'
            }
            steps {
                script {
                    def userInput = input(
                        id: 'confirmDestroy', message: 'Do you want to DESTROY infrastructure?',
                        parameters: [
                            [$class: 'BooleanParameterDefinition', defaultValue: false, description: 'Check to confirm destruction', name: 'confirm']
                        ]
                    )
                    if (userInput == false) {
                        error "Destroy cancelled by user"
                    }
                }
                dir('terraform') {
                    withCredentials([
                        file(credentialsId: 'TERRAFORM-TFVARS', variable: 'TFVARS_FILE'),
                        file(credentialsId: 'GCP_CREDS_JSON', variable: 'GOOGLE_CREDENTIALS')
                    ]) {
                        sh """
                            terraform destroy -auto-approve -var "google_credentials_file=${GOOGLE_CREDENTIALS}" -var-file="${TFVARS_FILE}"
                        """
                    }
                }
            }
        }
    }
}
