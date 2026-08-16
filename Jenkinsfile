pipeline {

    agent any

    environment {
        JAVA_HOME = 'C:\\Program Files\\Eclipse Adoptium\\jdk-17.0.20.8-hotspot'
        PATH = "${JAVA_HOME}\\bin;${env.PATH}"
    }

    stages {

        stage('Verify Tools') {
            steps {
                bat '''
                    echo ===== VERIFYING TOOLS =====
                    git --version
                    java -version
                    mvn -version
                    node -v
                    npm -v
                '''
            }
        }

        stage('Build') {
            steps {
                bat '''
                    echo ===== STARTING NAUKRI BUILD =====
                    powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%WORKSPACE%\\build\\build.ps1" -Variant Ship
                '''
            }
        }

        stage('Verify Artifact') {
            steps {
                bat '''
                    echo ===== CHECKING BUILD OUTPUT =====
                    dir "%WORKSPACE%\\dist"

                    if not exist "%WORKSPACE%\\dist\\NaukriAutomator Setup 0.1.0.exe" (
                        echo ERROR: Installer not found
                        exit /b 1
                    )

                    echo Installer found successfully
                '''
            }
        }

        stage('Archive Artifact') {
            steps {
                archiveArtifacts artifacts: 'dist/NaukriAutomator Setup 0.1.0.exe',
                                 fingerprint: true
            }
        }
    }

    post {
        success {
            echo '===================================='
            echo ' NAUKRI CI BUILD SUCCESSFUL'
            echo '===================================='
        }

        failure {
            echo '===================================='
            echo ' NAUKRI CI BUILD FAILED'
            echo '===================================='
        }
    }
}