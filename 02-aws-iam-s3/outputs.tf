output "intern" {

  value = aws_iam_user.intern.name

}

output "cloud_engineer" {

  value = aws_iam_user.cloud_engineer.name
}

output "Cloud_engineer_Bucket" {

  value = aws_s3_bucket.Cloud_engineer_Bucket.bucket

}

output "Intern_Bucket_Name" {

  value = aws_s3_bucket.intern_bucket.bucket

}