locals {
  deploy_cloudtrail = var.existing_cloudtrail_config == null || (var.existing_cloudtrail_config != null && var.existing_cloudtrail_config.cloudtrail_sns_arn == "create" && var.existing_cloudtrail_config.cloudtrail_s3_sns_sqs_arn == null)

  cloudtrail_sns_arn = local.deploy_cloudtrail ? module.cloudtrail[0].cloudtrail_sns_arn : var.existing_cloudtrail_config.cloudtrail_sns_arn
  cloudtrail_s3_arn  = local.deploy_cloudtrail ? module.cloudtrail[0].s3_bucket_arn : var.existing_cloudtrail_config.cloudtrail_s3_arn
}


module "cloudtrail" {
  count  = local.deploy_cloudtrail ? 1 : 0
  source = "../../modules/infrastructure/cloudtrail"
  name   = var.name

  is_organizational = true
  organizational_config = {
    sysdig_secure_for_cloud_member_account_id = var.sysdig_secure_for_cloud_member_account_id
    organizational_role_per_account           = var.organizational_member_default_admin_role
  }
  is_multi_region_trail            = var.cloudtrail_is_multi_region_trail
  cloudtrail_kms_enable            = var.cloudtrail_kms_enable
  s3_bucket_expiration_days        = var.cloudtrail_s3_bucket_expiration_days
  temporary_s3_bucket_public_block = var.temporary_cloudtrail_s3_bucket_public_block
  tags                             = var.tags
}
