resource "aws_apprunner_service" "cloudconnector" {
  service_name = var.name

  source_configuration {
    image_repository {
      image_configuration {
        port = "5000"
        runtime_environment_variables = {
          CONFIG_PATH                 = "s3://${local.s3_bucket_config_id}/cloud-connector.yaml"
          SECURE_API_TOKEN            = var.sysdig_secure_api_token
          SECURE_URL                  = var.sysdig_secure_url
          VERIFY_SSL                  = local.verify_ssl
          TELEMETRY_DEPLOYMENT_METHOD = "terraform_aws_apprunner_single"
        }
      }
      image_identifier      = var.cloudconnector_ecr_image_uri
      image_repository_type = "ECR_PUBLIC"
    }
    auto_deployments_enabled = false
  }

  instance_configuration {
    instance_role_arn = aws_iam_role.secure_for_cloud_role.arn
  }

  tags = var.tags
}

resource "aws_iam_role" "secure_for_cloud_role" {
  name               = "${var.name}-SecureForCloudRole"
  assume_role_policy = data.aws_iam_policy_document.sysdig_secure_for_cloud_role_trusted.json
  tags               = var.tags
}

resource "aws_iam_role_policy" "secure_for_cloud_role" {
  name   = "${var.name}-SecureForCloudRolePolicy"
  role   = aws_iam_role.secure_for_cloud_role.id
  policy = data.aws_iam_policy_document.cloud_connector.json
}

data "aws_iam_policy_document" "sysdig_secure_for_cloud_role_trusted" {
  statement {
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["tasks.apprunner.amazonaws.com"]
    }
    actions = ["sts:AssumeRole"]
  }
}

data "aws_iam_policy_document" "cloud_connector" {
  statement {
    sid    = "AllowS3"
    effect = "Allow"
    actions = [
      "s3:ListBucket",
      "s3:GetObject"
    ]
    resources = ["*"]
  }
  statement {
    sid    = "AllowSQS"
    effect = "Allow"
    actions = [
      "sqs:GetQueueUrl",
      "sqs:ListQueues",
      "sqs:ReceiveMessage",
      "sqs:DeleteMessage"
    ]
    resources = ["*"]
  }
  statement {
    sid    = "AllowECR"
    effect = "Allow"
    actions = [
      "ecr:GetDownloadUrlForLayer",
      "ecr:BatchGetImage",
      "ecr:DescribeImages",
      "ecr:GetAuthorizationToken",
      "ecr:BatchCheckLayerAvailability"
    ]
    resources = ["*"]
  }
  statement {
    sid    = "AllowCodebuild"
    effect = "Allow"
    actions = [
      "codebuild:StartBuild"
    ]
    resources = [var.build_project_arn]
  }
  statement {
    sid    = "AllowSSM"
    effect = "Allow"
    actions = [
      "ssm:GetParameters"
    ]
    resources = [var.secure_api_token_secret_arn]
  }
}
