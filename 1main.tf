resource "aws_s3_bucket" "Jenkins_Bucket" {
  bucket_prefix = "jenkins-bucket-"
  force_destroy = true

  tags = {
    Name = "Jenkins Bucket"
  }
}

resource "aws_s3_bucket_public_access_block" "public_access" {
  bucket = aws_s3_bucket.Jenkins_Bucket.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false

}

resource "aws_s3_bucket_policy" "s3_public_access_policy" {
  bucket = aws_s3_bucket.Jenkins_Bucket.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "PublicReadGetObject"
        Effect    = "Allow"
        Principal = "*"
        Action    = "s3:GetObject"
        Resource  = "${aws_s3_bucket.Jenkins_Bucket.arn}/*"
      },
    ]
  })

  depends_on = [aws_s3_bucket_public_access_block.public_access]
}


# resource "aws_s3_object" "Armageddon_Evidence_Link" {
#   bucket       = aws_s3_bucket.Jenkins_Bucket.id
#   key          = "armageddon_evidence_files/Armageddon_Group_Link.txt"
#   source       = "${path.module}/armageddon_evidence_files/Armageddon_Group_Link.txt"
#   content_type = "text/plain"
# }

# resource "aws_s3_object" "Armageddon_Evidence_Approval" {
#   bucket       = aws_s3_bucket.Jenkins_Bucket.id
#   key          = "armageddon_evidence_files/Theo_Armageddon_Approval.png"
#   source       = "${path.module}/armageddon_evidence_files/Theo_Armageddon_Approval.png"
#   content_type = "image/png"
# }

# resource "aws_s3_object" "Lab_Evidence" {
#   for_each = fileset("${path.module}/lab_evidence", "**")

#   bucket       = aws_s3_bucket.Jenkins_Bucket.id
#   key          = "lab_evidence/${each.value}"
#   source       = "${path.module}/lab_evidence/${each.value}"
#   content_type = "image/png"
