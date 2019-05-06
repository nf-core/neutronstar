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
                sh "mkdir -p NGI_micro10X_NA12878; cd NGI_micro10X_NA12878; \
                wget -nc https://github.com/nf-core/test-datasets/raw/neutronstar/tests/NGI_micro10X_NA12878/ngimicro10x_S1_L001_I1_001.fastq.gz; \
                wget -nc https://github.com/nf-core/test-datasets/raw/neutronstar/tests/NGI_micro10X_NA12878/ngimicro10x_S1_L001_R1_001.fastq.gz; \
                wget -nc https://github.com/nf-core/test-datasets/raw/neutronstar/tests/NGI_micro10X_NA12878/ngimicro10x_S1_L001_R2_001.fastq.gz;"
            }
        }
        stage('Build') {
            steps {
                sh "nextflow run nf-core/neutronstar -r jenkins -profile standard,jenkins -latest --id=testrun --fastqs=NGI_micro10X_NA12878/ --maxreads=all --accept_extreme_coverage --nopreflight"
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
