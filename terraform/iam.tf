resource "aws_iam_user" "jenkins_deploy" {
  name = "${var.project_name}-s3-sync"
  path = "/service/"

  tags = {
    Name      = "${var.project_name}-s3-sync"
    ManagedBy = "terraform"
  }
}

data "aws_iam_policy_document" "jenkins_s3" {
  statement {
    sid    = "ListBucket"
    effect = "Allow"
    actions = [
      "s3:ListBucket",
    ]
    resources = [
      aws_s3_bucket.site.arn,
    ]
  }

  statement {
    sid    = "ObjectRW"
    effect = "Allow"
    actions = [
      "s3:GetObject",
      "s3:PutObject",
      "s3:DeleteObject",
    ]
    resources = [
      "${aws_s3_bucket.site.arn}/*",
    ]
  }
}

resource "aws_iam_user_policy" "jenkins_s3" {
  name   = "${var.project_name}-s3-sync"
  user   = aws_iam_user.jenkins_deploy.name
  policy = data.aws_iam_policy_document.jenkins_s3.json
}

resource "aws_iam_access_key" "jenkins_deploy" {
  user = aws_iam_user.jenkins_deploy.name
}
