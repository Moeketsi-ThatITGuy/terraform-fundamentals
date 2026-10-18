resource "aws_iam_user" "intern" {


  name = var.intern
  tags = {
    description = "intern"
  }
}


resource "aws_iam_user" "cloud_engineer" {


  name = var.cloud_engineer
  tags = {
    description = "Cloud Engineer"

  }

}


resource "aws_iam_policy" "intern_policy" {


  name = "intern_policy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowReadInternBucket"
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:ListBucket"
        ]
        Resource = [
          aws_s3_bucket.intern_bucket.arn,
          "${aws_s3_bucket.intern_bucket.arn}/*"
        ]
      },
      {
        Sid    = "DenyAccessCloudEngineerBucket"
        Effect = "Deny"
        Action = "s3:*"
        Resource = [
          aws_s3_bucket.Cloud_engineer_Bucket.arn,
          "${aws_s3_bucket.Cloud_engineer_Bucket.arn}/*"
        ]
      }
    ]
  })

}

resource "aws_iam_policy" "cloud_engineer_policy" {
  name = "cloud_engineer_policy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowFullAccessBothBuckets"
        Effect = "Allow"
        Action = "s3:*"
        Resource = [
          aws_s3_bucket.intern_bucket.arn,
          "${aws_s3_bucket.intern_bucket.arn}/*",
          aws_s3_bucket.Cloud_engineer_Bucket.arn,
          "${aws_s3_bucket.Cloud_engineer_Bucket.arn}/*"
        ]
      }
    ]
  })
}




resource "aws_iam_user_policy_attachment" "Intern_S3_Policy" {


  user       = aws_iam_user.intern.name
  policy_arn = aws_iam_policy.intern_policy.arn

}

resource "aws_iam_user_policy_attachment" "Cloud_Engineer_S3_Bucket" {


  user       = aws_iam_user.cloud_engineer.name
  policy_arn = aws_iam_policy.cloud_engineer_policy.arn
}




resource "aws_s3_bucket" "intern_bucket" {

  bucket = var.intern_bucket_name
  tags = {
    Description = "Intern Bucket"
  }
}

resource "aws_s3_bucket" "Cloud_engineer_Bucket" {

  bucket = var.engineer_bucket_name
  tags = {
    Description = "Cloud Engineer Bucket"
  }
}

