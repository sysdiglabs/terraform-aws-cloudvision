variable "org_cloudvision_account_id" {
  type        = string
  description = "the account_id **within the organization** to be used as cloudvision account"

}

variable "sysdig_secure_api_token" {
  sensitive   = true
  type        = string
  description = "Sysdig Secure API token"
}




#------------------------------
# optionals - with defaults
#------------------------------

variable "sysdig_secure_endpoint" {
  type        = string
  default     = "https://secure.sysdig.com"
  description = "Sysdig Secure API endpoint"
}

variable "aws_connection_profile" {
  type        = string
  default     = "default"
  description = "AWS connection profile to be used on ~/.aws/credentials for organization master account"
}

variable "region" {
  type        = string
  description = "default region for provisioning"
  default     = "eu-central-1"
}
