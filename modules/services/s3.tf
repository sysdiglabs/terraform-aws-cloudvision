data "aws_caller_identity" "me" {}

resource "aws_s3_bucket" "s3_config_bucket" {
  bucket        = "${var.name}-${data.aws_caller_identity.me.account_id}-config"
  acl           = "private"
  force_destroy = true

  versioning {
    enabled = true
  }
  tags = var.tags
}

resource "aws_s3_bucket_policy" "allow_cloudvision_role" {
  bucket = aws_s3_bucket.s3_config_bucket.id
  policy = data.aws_iam_policy_document.allow_cloudvision_role.json
}

data "aws_iam_policy_document" "allow_cloudvision_role" {
  statement {
    sid    = "Allow Cloudvision role"
    effect = "Allow"
    principals {
      identifiers = [var.services_assume_role_arn]
      type        = "AWS"
    }
    actions = [
      "s3:Get*",
      "s3:List*",
    ]
    resources = [aws_s3_bucket.s3_config_bucket.arn]
  }
}
