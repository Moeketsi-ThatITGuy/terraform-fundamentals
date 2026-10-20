resource "aws_iam_group" "group" {
  name = var.group_name
  path = var.path
}