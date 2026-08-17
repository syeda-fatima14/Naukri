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
                    echo ========================================
                    echo VERIFYING TOOLS
                    echo ========================================

                    git --version
                    java -version
                    mvn -version
                    node -v
                    npm -v
                    terraform --version
                    wsl --status

                    echo Tools verification completed.
                '''
            }
        }

        stage('Build') {
            steps {
                bat '''
                    echo ========================================
                    echo STARTING NAUKRI BUILD
                    echo ========================================

                    powershell.exe -NoProfile -ExecutionPolicy Bypass ^
                    -File "%WORKSPACE%\\build\\build.ps1" -Variant Ship

                    if errorlevel 1 (
                        echo ERROR: Naukri build failed
                        exit /b 1
                    )

                    echo Build completed successfully.
                '''
            }
        }

        stage('Verify Artifact') {
            steps {
                bat '''
                    echo ========================================
                    echo CHECKING BUILD OUTPUT
                    echo ========================================

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

        stage('Prepare Deployment') {
            steps {
                bat '''
                    echo ========================================
                    echo PREPARING DEPLOYMENT
                    echo ========================================

                    if not exist "%DEPLOY_DIR%" (
                        mkdir "%DEPLOY_DIR%"
                    )

                    echo Copying installer to deployment directory...

                    copy /Y "%WORKSPACE%\\dist\\%INSTALLER%" "%DEPLOY_DIR%\\%INSTALLER%"

                    if errorlevel 1 (
                        echo ERROR: Failed to copy installer
                        exit /b 1
                    )

                    echo Installer copied successfully.
                '''
            }
        }

        stage('Terraform') {
    steps {
        withCredentials([
            usernamePassword(
                credentialsId: 'azure-sp',
                usernameVariable: 'ARM_CLIENT_ID',
                passwordVariable: 'ARM_CLIENT_SECRET'
            )
        ]) {
            bat '''
                echo ========================================
                echo TERRAFORM
                echo ========================================

                set ARM_TENANT_ID=4ccef82a-6b33-47c2-8540-09d999da9130
                set ARM_SUBSCRIPTION_ID=d1c5d987-0777-4d6f-9eba-e11f1f4012f5

                cd /d "%WORKSPACE%\\terraform"

                echo ===== TERRAFORM INIT =====
                terraform init

                if errorlevel 1 (
                    echo ERROR: Terraform init failed
                    exit /b 1
                )

                echo ===== TERRAFORM VALIDATE =====
                terraform validate

                if errorlevel 1 (
                    echo ERROR: Terraform validation failed
                    exit /b 1
                )

                echo ===== TERRAFORM PLAN =====
                terraform plan

                if errorlevel 1 (
                    echo ERROR: Terraform plan failed
                    exit /b 1
                )

                echo ===== TERRAFORM APPLY =====
                terraform apply -auto-approve

                if errorlevel 1 (
                    echo ERROR: Terraform apply failed
                    exit /b 1
                )

                echo Terraform completed successfully.
            '''
        }
    }
}
        stage('Ansible Deployment') {
            steps {
                bat '''
                    echo ========================================
                    echo ANSIBLE DEPLOYMENT
                    echo ========================================

                    echo Running Ansible through WSL...

                    wsl bash -lc "cd ~/naukri-ansible && ansible-playbook deploy.yml"

                    if errorlevel 1 (
                        echo ERROR: Ansible deployment failed
                        exit /b 1
                    )

                    echo.
                    echo Ansible deployment completed successfully.
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

                    echo Installer successfully transferred.

                    echo.
                    echo Verifying installed application...

                    if not exist "C:\\Windows\\SysWOW64\\config\\systemprofile\\AppData\\Local\\Programs\\NaukriAutomator\\NaukriAutomator.exe" (
                        echo ERROR: Naukri application was not found after deployment
                        exit /b 1
                    )

                    echo Naukri application found successfully.
                    echo Deployment verified successfully.
                '''
            }
        }
    }

    post {

        success {
            echo '========================================'
            echo ' NAUKRI CI/CD SUCCESSFUL'
            echo ' BUILD + TERRAFORM + ANSIBLE + DEPLOYMENT COMPLETED'
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