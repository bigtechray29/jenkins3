/*
 * Git webhook (GitHub, GitLab, etc.):
 * 1. Install Jenkins plugin: "Generic Webhook Trigger".
 * 2. In the Git host: add a webhook POST on push to:
 *    http://YOUR_JENKINS/generic-webhook-trigger/invoke?token=jenkins4-git-webhook
 *    GitHub: Settings → Webhooks → application/json → "Just the push event".
 * 3. Token must match `token` in triggers below (change both if you rotate it).
 * Native GitHub alternative (no plugin in Jenkinsfile): job → "GitHub hook trigger for GITScm polling"
 * and webhook URL http://YOUR_JENKINS/github-webhook/
 */
pipeline {
    agent any

    triggers {
        GenericTrigger(
            causeString: 'Git webhook $ref',
            genericVariables: [
                [key: 'ref', value: '$.ref', defaultValue: ''],
                [key: 'after', value: '$.after', defaultValue: ''],
            ],
            regexpFilterText: '$ref',
            regexpFilterExpression: '^refs/heads/(main|master)$',
            printContributedVariables: true,
            printPostContent: false,
            silentResponse: false,
            token: 'jenkins4-git-webhook'
        )
    }

    parameters {
        string(name: 'S3_BUCKET', defaultValue: '', description: 'S3 bucket name from Terraform output s3_bucket_name (no s3:// prefix)')
        string(name: 'AWS_REGION', defaultValue: 'eu-west-1', description: 'AWS region for the bucket')
        string(
            name: 'AWS_CREDENTIALS_ID',
            defaultValue: 'Jenkins4',
            description: 'Jenkins credential ID: kind "Username with password" — username = Access Key ID, password = Secret Access Key'
        )
        string(name: 'SOURCE_DIR', defaultValue: 'deploy', description: 'Folder in the repo synced to the bucket root')
    }

    environment {
        AWS_DEFAULT_REGION = "${params.AWS_REGION}"
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Validate') {
            steps {
                script {
                    if (!params.S3_BUCKET?.trim()) {
                        error('Set job parameter S3_BUCKET (from terraform output) or edit the Jenkinsfile defaultValue.')
                    }
                }
            }
        }

        stage('Deploy to S3') {
            steps {
                withCredentials([
                    usernamePassword(
                        credentialsId: "${params.AWS_CREDENTIALS_ID}",
                        usernameVariable: 'AWS_ACCESS_KEY_ID',
                        passwordVariable: 'AWS_SECRET_ACCESS_KEY'
                    )
                ]) {
                    script {
                        if (isUnix()) {
                            sh """
                                set -e
                                if ! command -v aws >/dev/null 2>&1; then
                                    echo 'ERROR: AWS CLI is not installed on this agent.'
                                    exit 1
                                fi
                                aws sts get-caller-identity
                                aws s3 sync "${params.SOURCE_DIR}" "s3://${params.S3_BUCKET}/" \\
                                    --delete \\
                                    --region "${params.AWS_DEFAULT_REGION}" \\
                                    --only-show-errors
                                echo 'Bucket listing after sync:'
                                aws s3 ls "s3://${params.S3_BUCKET}/"
                            """
                        } else {
                            bat """
                                where aws >nul 2>&1
                                if errorlevel 1 (
                                    echo ERROR: AWS CLI is not installed on this agent.
                                    exit /b 1
                                )
                                aws sts get-caller-identity
                                aws s3 sync "${params.SOURCE_DIR}" "s3://${params.S3_BUCKET}/" --delete --region "${params.AWS_DEFAULT_REGION}" --only-show-errors
                                echo Bucket listing after sync:
                                aws s3 ls "s3://${params.S3_BUCKET}/"
                            """
                        }
                    }
                }
            }
        }
    }

    post {
        success {
            echo "Deployed to s3://${params.S3_BUCKET}/ (region ${params.AWS_REGION})"
        }
        failure {
            echo 'Check: Jenkins credential ID, IAM policy, bucket name, AWS CLI on the agent, and SOURCE_DIR exists.'
        }
    }
}
