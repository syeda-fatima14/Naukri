pipeline {

    agent any

    environment {
        JAVA_HOME = 'C:\\Program Files\\Eclipse Adoptium\\jdk-17.0.20.8-hotspot'
        PATH = "${JAVA_HOME}\\bin;${env.PATH}"

        DEPLOY_DIR = 'C:\\Naukri-Deploy'
        INSTALLER = 'NaukriAutomator Setup 0.1.0.exe'
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

                    powershell.exe -NoProfile -ExecutionPolicy Bypass ^
                    -File "%WORKSPACE%\\build\\build.ps1" -Variant Ship
                '''
            }
        }

        stage('Verify Artifact') {
            steps {
                bat '''
                    echo ===== CHECKING BUILD OUTPUT =====

                    dir "%WORKSPACE%\\dist"

                    if not exist "%WORKSPACE%\\dist\\%INSTALLER%" (
                        echo ERROR: Installer not found!
                        exit /b 1
                    )

                    echo Installer found successfully!
                '''
            }
        }

        stage('Archive Artifact') {
            steps {
                archiveArtifacts artifacts: 'dist/NaukriAutomator Setup 0.1.0.exe',
                                 fingerprint: true
            }
        }

        stage('Deploy') {
            steps {
                bat '''
                    echo ========================================
                    echo STARTING DEPLOYMENT
                    echo ========================================

                    if not exist "%DEPLOY_DIR%" (
                        mkdir "%DEPLOY_DIR%"
                    )

                    echo Copying installer...

                    copy /Y "%WORKSPACE%\\dist\\%INSTALLER%" "%DEPLOY_DIR%\\%INSTALLER%"

                    if errorlevel 1 (
                        echo ERROR: Failed to copy installer
                        exit /b 1
                    )

                    echo Installer copied successfully.

                    echo Installing application...

                    "%DEPLOY_DIR%\\%INSTALLER%" /S

                    if errorlevel 1 (
                        echo ERROR: Installation failed
                        exit /b 1
                    )

                    echo Installation completed successfully.
                '''
            }
        }

        stage('Verify Deployment') {
            steps {
                bat '''
                    echo ========================================
                    echo VERIFYING DEPLOYMENT
                    echo ========================================

                    if not exist "%DEPLOY_DIR%\\%INSTALLER%" (
                        echo ERROR: Deployed installer not found
                        exit /b 1
                    )

                    echo Deployment verified successfully.
                '''
            }
        }
    }

    post {

        success {
            echo '========================================'
            echo ' NAUKRI CI/CD SUCCESSFUL'
            echo ' BUILD + DEPLOYMENT COMPLETED'
            echo '========================================'
        }

        failure {
            echo '========================================'
            echo ' NAUKRI CI/CD FAILED'
            echo ' CHECK CONSOLE OUTPUT'
            echo '========================================'
        }
    }
}