variable "sysdig_secure_api_token" {
  sensitive   = true
  type        = string
  description = "Sysdig Secure API token"
}

variable "org_cloudvision_member_account_id" {
  type        = string
  description = "the **account id within the organization** to be used as cloudvision account"
}

variable "org_cloudvision_account_region" {
  type        = string
  description = "default cloudvision member account region for services provisioning"
}


# --------------------
# cloudtrail configuration
# --------------------

variable "cloudtrail_org_is_multi_region_trail" {
  type        = bool
  default     = true
  description = "testing/economization purpose. true/false whether cloudtrail will ingest multiregional events"
}

variable "cloudtrail_org_kms_enable" {
  type        = bool
  default     = true
  description = "testing/economization purpose. true/false whether s3 should be encrypted"
}



#---------------------------------
# optionals - with defaults
#---------------------------------
variable "name" {
  type        = string
  description = "Name for the Cloud Vision deployment"
  default     = "sysdig-cloudvision"
}

variable "sysdig_secure_endpoint" {
  type        = string
  default     = "https://secure.sysdig.com"
  description = "Sysdig Secure API endpoint"
}

variable "tags" {
  type        = map(string)
  description = "sysdig cloudvision tags"
  default = {
    "product" = "sysdig-cloudvision"
  }
}
