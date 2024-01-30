pipeline {
    agent any

    environment {
        // Nexus environment variables
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
                script {
                    try {
                        git 'https://github.com/vanthiyadhevan/login_with_vprofile.git'
                        echo 'GitHub repository checkout successful.'
                    } catch (Exception e) {
                        currentBuild.result = 'FAILURE'
                        error "Failed to checkout GitHub repository: ${e.message}"
                    }
                }
            }
        }

        stage('BUILD') {
            steps {
                script {
                    sh 'mvn clean install -DskipTests'
                }
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
                    try {
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
                    } catch (Exception e) {
                        currentBuild.result = 'FAILURE'
                        error "Failed to publish to Nexus: ${e.message}"
                    }
                }
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    try {
                        def warFilePath = sh(script: 'ls target/*.war', returnStdout: true).trim()
                        dockerImage = docker.build("${DOCKER_IMAGE_NAME}:${DOCKER_IMAGE_TAG}", "--build-arg WAR_FILE=${warFilePath} .")
                    } catch (Exception e) {
                        currentBuild.result = 'FAILURE'
                        error "Failed to build Docker image: ${e.message}"
                    }
                }
            }
        }

        stage('Push Docker Image to Docker Hub') {
            steps {
                script {
                    try {
                        withCredentials([usernamePassword(credentialsId: 'docker', passwordVariable: 'VickeY.v@+2612410', usernameVariable: 'DOCKER_USERNAME')]) {
                            docker.withRegistry('https://registry.hub.docker.com', 'docker') {
                                dockerImage.push('latest')
                            }
                        }
                    } catch (Exception e) {
                        currentBuild.result = 'FAILURE'
                        error "Failed to push Docker image to Docker Hub: ${e.message}"
                    }
                }
            }
        }

        stage('Stop Previous Running Service') {
            steps {
                script {
                    try {
                        def containerId = sh(script: 'docker ps -q -f name=login', returnStdout: true).trim()

                        if (containerId) {
                            echo "Stopping the running container with ID: ${containerId}"
                            sh "docker stop ${containerId}"
                        } else {
                            echo "No running container found with the name 'login'. Nothing to stop."
                        }
                    } catch (Exception e) {
                        currentBuild.result = 'FAILURE'
                        error "Failed to stop the container: ${e.message}"
                    }
                }
            }
        }

        stage('Remove stopped Service') {
            steps {
                script {
                    try {
                        def stoppedContainerId = sh(script: 'docker ps -aq -f status=exited -f name=login', returnStdout: true).trim()

                        if (stoppedContainerId) {
                            echo "Removing the stopped container with ID: ${stoppedContainerId}"
                            sh "docker rm ${stoppedContainerId}"
                            echo 'Container removed successfully.'
                        } else {
                            echo "No stopped container found with the name 'login'. Nothing to remove."
                        }
                    } catch (Exception e) {
                        currentBuild.result = 'FAILURE'
                        error "Failed to remove the container: ${e.message}"
                    }
                }
            }
        }

        stage('Run in local machine') {
            steps {
                script {
                    try {
                        sh 'docker run -d --name login -p 8085:8080 ${DOCKER_IMAGE_NAME}:${DOCKER_IMAGE_TAG}'
                        echo 'Container started successfully in local machine.'
                    } catch (Exception e) {
                        currentBuild.result = 'FAILURE'
                        error "Failed to start the container in local machine: ${e.message}"
                    }
                }
            }
        }
    }
}
