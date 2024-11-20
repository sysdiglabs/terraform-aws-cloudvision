resource "aws_codebuild_project" "build_project" {
  name        = "${var.name}-BuildProject"
  description = "CodeBuild project which scans images using inline technology"

  service_role = aws_iam_role.service.arn

  artifacts {
    type = "NO_ARTIFACTS"
  }

  environment {
    compute_type    = "BUILD_GENERAL1_MEDIUM"
    image           = "aws/codebuild/standard:5.0"
    type            = "LINUX_CONTAINER"
    privileged_mode = "true"
  }

  logs_config {
    cloudwatch_logs {
      group_name = aws_cloudwatch_log_group.log.name
    }
  }

  source {
    type = "NO_SOURCE"
    buildspec = yamlencode({
      version = "0.2"
      phases = {
        build = {
          commands = ["exit"]
        }
      }
    })
  }

  tags = var.tags
}
