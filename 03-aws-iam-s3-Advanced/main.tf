
module "engineer_bucket" {

  source      = "./modules/s3-bucket"
  bucket_name = "engineer-bucket-terraform-practice"
  team        = "engineers"
}


module "intern_bucket" {

  source      = "./modules/s3-bucket"
  bucket_name = "intern-bucket-terraform-practice"
  team        = "interns"
}

module "intern_group" {
  source     = "./modules/aws-groups"
  group_name = "interns"
  path       = "/team/interns/"
}

module "engineer_group" {

  source     = "./modules/aws-groups"
  group_name = "engineers"
  path       = "/teams/engineers/"
}

resource "aws_iam_group_membership" "engineer_membership" {
  name  = "engineer_membership"
  group = module.engineer_group.group_name
  users = [for user in aws_iam_user.engineers : user.name]
}

resource "aws_iam_group_membership" "intern_membership" {
  name  = "intern_membership"
  group = module.intern_group.group_name
  users = [for user in aws_iam_user.interns : user.name]
}



resource "aws_iam_user" "interns" {

  for_each = var.interns
  name     = each.value

}

resource "aws_iam_user" "engineers" {

  for_each = var.cloud_engineers
  name     = each.value

}

resource "aws_iam_group_policy" "intern_group_policy" {
  name  = "intern_group_policy"
  group = module.intern_group.group_name
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid      = "AllowListInternBucket"
        Effect   = "Allow"
        Action   = "s3:ListBucket"
        Resource = module.intern_bucket.bucket_arn
      },
      {
        Sid    = "DenyAccessCloudEngineerBucket"
        Effect = "Deny"
        Action = "s3:*"
        Resource = [
          module.engineer_bucket.bucket_arn,
          "${module.engineer_bucket.bucket_arn}/*"
        ]
      }
    ]
  })

}



resource "aws_iam_group_policy" "engineer_group_policy" {
  name  = "engineer_group_policy"
  group = module.engineer_group.group_name
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowFullAccessBothBuckets"
        Effect = "Allow"
        Action = "s3:*"
        Resource = [
          module.intern_bucket.bucket_arn,
          "${module.intern_bucket.bucket_arn}/*",
          module.engineer_bucket.bucket_arn,
          "${module.engineer_bucket.bucket_arn}/*"

        ]
      }
    ]
  })

}

resource "aws_iam_group_policy" "engineer_prefix" {
  name  = "engineer_prefix"
  group = module.engineer_group.group_name
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect   = "Allow"
      Action   = "s3:*"
      Resource = "${module.engineer_bucket.bucket_arn}/$${aws:username}/*"
    }]
  })
}


resource "aws_iam_group_policy" "intern_prefix" {
  name  = "intern_prefix"
  group = module.intern_group.group_name
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect   = "Allow"
      Action   = "s3:*"
      Resource = "${module.intern_bucket.bucket_arn}/$${aws:username}/*"
    }]
  })
}
