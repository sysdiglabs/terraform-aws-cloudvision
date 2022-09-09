#---------------------------------
# optionals - with defaults
#---------------------------------

#
# module composition
#

variable "is_organizational" {
  type        = bool
  default     = false
  description = "true/false whether cloudtrail is organizational or not"
}


variable "organizational_config" {
  type = object({
    sysdig_secure_for_cloud_member_account_id = string
    organizational_role_per_account           = string
  })
  default = {
    sysdig_secure_for_cloud_member_account_id = null
    organizational_role_per_account           = null
  }
  description = <<-EOT
    organizational_config. following attributes must be given
    <ul><li>`sysdig_secure_for_cloud_member_account_id` to enable reading permission</li>
    <li>`organizational_role_per_account` to enable SNS topic subscription. by default "OrganizationAccountAccessRole"</li></ul>
  EOT
}

#
# module config
#

variable "s3_bucket_expiration_days" {
  type        = number
  default     = 5
  description = "Number of days that the logs will persist in the bucket"
}

variable "cloudtrail_kms_enable" {
  type        = bool
  default     = true
  description = "true/false whether cloudtrail delivered events to S3 should persist encrypted. If `var.cloudtrail_kms_arn` is set, then the pre-existing KMS key will be used, otherwise a new KMS key will be created"
}

variable "cloudtrail_kms_arn" {
  type        = string
  default     = null
  description = "When `var.cloudtrail_kms_enable` is set to true, ARN of a pre-existing KMS key for encrypting the Cloudtrail logs"
}

variable "is_multi_region_trail" {
  type        = bool
  default     = true
  description = "true/false whether cloudtrail will ingest multiregional events"
}


#
# general
#

variable "name" {
  type        = string
  default     = "sfc"
  description = "Name to be assigned to all child resources. A suffix may be added internally when required. Use default value unless you need to install multiple instances"
}

variable "tags" {
  type        = map(string)
  description = "sysdig secure-for-cloud tags. always include 'product' default tag for resource-group proper functioning"
  default = {
    "product" = "sysdig-secure-for-cloud"
  }
}
