pipeline {
    agent any

    environment {
        // Add your existing environment variables here
        NEXUS_VERSION = "nexus3"
        NEXUS_PROTOCOL = "http"
        NEXUS_URL = "192.168.1.25:8081/"
        NEXUS_REPOSITORY = "vprofile-docker"
        NEXUS_REPO_ID = "vprofile-docker"
        NEXUS_CREDENTIAL_ID = "nexus3"
        ARTVERSION = "${env.BUILD_ID}-${env.BUILD_TIMESTAMP}"

        // Docker related variables
        DOCKER_USERNAME = "vanthiyadevan"
        DOCKER_IMAGE_NAME = "vanthiyadevan/vprofile"
        DOCKER_IMAGE_TAG = "${env.BUILD_ID}-${env.BUILD_TIMESTAMP}"
        DOCKER_HUB_CREDENTIAL_ID = "docker"
    }

    stages {
        stage('Checkout') {
            steps {
                git 'https://github.com/vanthiyadhevan/login_with_vprofile.git'
            }
        }
        stage('BUILD') {
            steps {
                sh 'mvn clean install -DskipTests'
            }
            post {
                success {
                    echo 'Now Archiving...'
                    archiveArtifacts artifacts: '**/target/*.war'
                }
            }
        }
        
        stage("Publish to Nexus Repository Manager") {
            steps {
                script {
                    // Your existing Nexus publishing code
                    pom = readMavenPom file: 'pom.xml'
                    def artifactPath = findFiles(glob: 'target/vprofile-v2.war')[0]

                    if (artifactPath) {
                        nexusArtifactUploader(
                            nexusVersion: NEXUS_VERSION,
                            protocol: NEXUS_PROTOCOL,
                            nexusUrl: NEXUS_URL,
                            groupId: pom.groupId,
                            version: "${env.BUILD_ID}-${env.BUILD_TIMESTAMP}",
                            repository: NEXUS_REPOSITORY,
                            credentialsId: NEXUS_CREDENTIAL_ID,
                            artifacts: [
                                [artifactId: 'vproapp',
                                classifier: '',
                                file: 'target/vprofile-v2.war',
                                type: 'war']
                            ]
                        )
                    } else {
                        error "*** File: ${artifactPath}, could not be found"
                    }
                }
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    def warFilePath = sh(script: 'ls target/*.war', returnStdout: true).trim()
                    dockerImage = docker.build("${DOCKER_IMAGE_NAME}:${DOCKER_IMAGE_TAG}", "--build-arg WAR_FILE=${warFilePath} .")
                }
            }
        }

        stage('Push Docker Image to Docker Hub') {
            steps {
                script {
                    withCredentials([usernamePassword(credentialsId: 'docker', passwordVariable: 'VickeY.v@+2612410', usernameVariable: 'DOCKER_USERNAME')]) {
                        docker.withRegistry('https://registry.hub.docker.com', 'docker') {
                            dockerImage.push('latest')
                        }
                    }
                }
            }
        }
        stage('Stop Previous Running Service') {
            steps {
                script {
                    sh 'docker stop login'
                }
            }
        }
        stage('Remove stoped Service') {
            steps {
                script {
                    sh 'docker rm login'
                }
            }
            
        }
        stage('Run in local machine') {
            steps {
                script {
                    sh 'docker run -d --name login -p 8085:8080 ${DOCKER_IMAGE_NAME}:${DOCKER_IMAGE_TAG}'
                }
            }
        }
    }
}