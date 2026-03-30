variable "aws_region" {
  description = "AWS region for the S3 bucket and IAM resources."
  type        = string
  default     = "us-west-1"
}

variable "project_name" {
  description = "Short name used in resource tags and IAM user name (letters, numbers, hyphen)."
  type        = string
  default     = "jenkins-deploy"
}

variable "bucket_name_prefix" {
  description = "S3 bucket name prefix; a random suffix is appended for global uniqueness."
  type        = string
  default     = "jenkins-static-site"
}
