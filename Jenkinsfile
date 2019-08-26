pipeline {
    agent any

    environment {
        JENKINS_API = credentials('api')
    }

    stages {
        stage('Setup environment') {
            steps {
                sh "pip install nf-core"
                sh "docker pull nfcore/neutronstar:dev"
                sh "docker pull nfcore/supernova"
                sh "docker tag nfcore/neutronstar:dev nfcore/neutronstar:latest"
                sh "rm -rf test-datasets"
                sh "git clone --single-branch --branch neutronstar https://github.com/nf-core/test-datasets.git test-datasets"
            }
        }
        stage('Build') {
            steps {
                sh "nextflow run nf-core/neutronstar -r dev -profile docker,jenkins -latest --id=testrun --fastqs=test-datasets/tests/NGI_micro10X_NA12878/ --maxreads=all --nopreflight"
                sh "rm -rf work/ .nextflow* results/"
            }
        }
    }

    post {
        failure {
            script {
                def response = sh(script: "curl -u ${JENKINS_API_USR}:${JENKINS_API_PSW} ${BUILD_URL}/consoleText", returnStdout: true).trim().replace('\n', '<br>')
                def comment = pullRequest.comment("##:rotating_light: Buil log output:<br><summary><details>${response}</details></summary>")
            }
        }
    }
}
