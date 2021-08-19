#
# Sysdig Secure cloud provisioning
#
resource "sysdig_secure_cloud_account" "cloud_account" {
  account_id     = var.account_id
  cloud_provider = "aws"
  role_enabled   = "true"
}

data "sysdig_secure_trusted_cloud_identity" "trusted_sysdig_role" {
  cloud_provider = "aws"
}


#
# aws role provisioning
#

resource "aws_iam_role" "cloudbench_role" {
  name               = "SysdigCloudBench"
  assume_role_policy = data.aws_iam_policy_document.trust_relationship.json
  tags               = var.tags
}

data "aws_iam_policy_document" "trust_relationship" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      type        = "AWS"
      identifiers = [data.sysdig_secure_trusted_cloud_identity.trusted_sysdig_role.identity]
    }
    condition {
      test     = "StringEquals"
      variable = "sts:ExternalId"
      values   = [sysdig_secure_cloud_account.cloud_account.external_id]
    }
  }
}



resource "aws_iam_role_policy_attachment" "cloudbench_security_audit" {
  role       = aws_iam_role.cloudbench_role.id
  policy_arn = data.aws_iam_policy.security_audit.arn
}

data "aws_iam_policy" "security_audit" {
  arn = "arn:aws:iam::aws:policy/SecurityAudit"
}
