provider "aws" {
  region = var.region
}

module "cloudvision" {
  source = "../../"

  providers = {
    aws.cloudvision = aws
  }
  name = var.name

  sysdig_secure_endpoint  = var.sysdig_secure_endpoint
  sysdig_secure_api_token = var.sysdig_secure_api_token


  # module composition
  enable_service_threat_detection = var.enable_service_threat_detection
  enable_service_image_scanning   = var.enable_service_image_scanning

  #  testing purpose; economization
  cloudtrail_is_multi_region_trail = var.cloudtrail_is_multi_region_trail
  cloudtrail_kms_enable            = var.cloudtrail_kms_enable

  tags = var.tags
}
