output "s3_bucket_name" {
  description = "Pass this to the Jenkins job parameter S3_BUCKET."
  value       = aws_s3_bucket.site.bucket
}

output "aws_region" {
  description = "Region where the bucket lives; use as Jenkins parameter AWS_REGION."
  value       = var.aws_region
}

output "iam_user_name" {
  description = "IAM user created for Jenkins (for your records)."
  value       = aws_iam_user.jenkins_deploy.name
}

output "jenkins_credential_username" {
  description = "Jenkins 'Username with password': set Username to this Access Key ID."
  value       = aws_iam_access_key.jenkins_deploy.id
  sensitive   = false
}

output "jenkins_credential_password" {
  description = "Jenkins 'Username with password': set Password to this Secret Access Key. Store securely; shown once in apply output."
  value       = aws_iam_access_key.jenkins_deploy.secret
  sensitive   = true
}
