resource "aws_iam_user_policy" "cloud_connector" {
  name   = "${var.name}-cc"
  user   = data.aws_iam_user.this.user_name
  policy = data.aws_iam_policy_document.cloud_connector.json
}

locals {
  # required for single vs. org management
  s3_resources_list = var.cloudtrail_s3_bucket_arn == "*" ? [var.cloudtrail_s3_bucket_arn] : [var.cloudtrail_s3_bucket_arn, "${var.cloudtrail_s3_bucket_arn}/*"]
}

data "aws_iam_policy_document" "cloud_connector" {
  statement {
    sid    = "AllowReadCloudtrailS3"
    effect = "Allow"
    actions = [
      "s3:ListBucket",
      "s3:GetObject"
    ]
    resources = local.s3_resources_list
  }

  statement {
    sid    = "AllowReadWriteCloudtrailSubscribedSQS"
    effect = "Allow"
    actions = [
      "sqs:ReceiveMessage",
      "sqs:DeleteMessage"
    ]
    resources = [var.cloudtrail_subscribed_sqs_arn]
  }

  # required for EKS
  statement {
    sid    = "AllowCloudwatchLogManagement"
    effect = "Allow"
    actions = [
      "logs:DescribeLogStreams",
      "logs:GetLogEvents",
      "logs:FilterLogEvents",
    ]
    resources = ["*"]
    # TODO. make an input-var out of this. make it more specific "arn:aws:logs:*:*:log-group:test:*"
  }
}
