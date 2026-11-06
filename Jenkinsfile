pipeline {
    agent any

    parameters {
        choice(
            name: 'ENVIRONMENT',
            choices: ['dev', 'staging', 'prod'],
            description: 'Target infrastructure environment'
        )
        choice(
            name: 'ACTION',
            choices: ['plan', 'apply', 'destroy'],
            description: 'Terraform action to perform'
        )
        string(
            name: 'EXTRA_VARS',
            defaultValue: '',
            description: 'Optional Terraform variables (e.g. -var="image_tag=12")'
        )
        booleanParam(
            name: 'AUTO_APPROVE',
            defaultValue: false,
            description: 'Auto-approve apply or destroy (skips interactive confirmation)'
        )
    }

    environment {
        AWS_DEFAULT_REGION = 'us-east-1'
        TF_IN_AUTOMATION   = 'true'
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Verify Environment') {
            steps {
                sh """
                    echo "Target Environment: ${params.ENVIRONMENT}"
                    echo "Action: ${params.ACTION}"
                    if [ ! -d "environments/${params.ENVIRONMENT}" ]; then
                        echo "Error: Directory environments/${params.ENVIRONMENT} does not exist!"
                        exit 1
                    fi
                """
            }
        }

        stage('Terraform Init') {
            steps {
                dir("environments/${params.ENVIRONMENT}") {
                    sh 'terraform init'
                }
            }
        }

        stage('Terraform Plan') {
            steps {
                dir("environments/${params.ENVIRONMENT}") {
                    script {
                        def extraVars = params.EXTRA_VARS ? "${params.EXTRA_VARS}" : ""
                        if (params.ACTION == 'destroy') {
                            sh "terraform plan -destroy ${extraVars} -out=tfplan"
                        } else {
                            sh "terraform plan ${extraVars} -out=tfplan"
                        }
                    }
                }
            }
        }

        stage('Approval Gate') {
            when {
                expression {
                    return (params.ACTION != 'plan' && !params.AUTO_APPROVE)
                }
            }
            steps {
                input message: "Approve '${params.ACTION}' on '${params.ENVIRONMENT}' environment?", ok: "Execute ${params.ACTION}"
            }
        }

        stage('Terraform Execute') {
            when {
                expression { params.ACTION != 'plan' }
            }
            steps {
                dir("environments/${params.ENVIRONMENT}") {
                    sh 'terraform apply -input=false tfplan'
                }
            }
        }
    }

    post {
        always {
            cleanWs(cleanWhenNotBuilt: false,
                    deleteDirs: true,
                    disableDeferredWipeout: true,
                    notFailBuild: true,
                    patterns: [[pattern: '**/tfplan', type: 'INCLUDE']])
        }
        success {
            echo "Successfully ran ${params.ACTION} on ${params.ENVIRONMENT} environment!"
        }
        failure {
            echo "Pipeline failed on ${params.ENVIRONMENT} environment. Check logs."
        }
    }
}
