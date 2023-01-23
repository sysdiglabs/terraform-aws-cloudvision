terraform {
  required_providers {
    sysdig = {
      source  = "sysdiglabs/sysdig"
      version = ">=0.5.33"
    }
    aws = {
      source  = "hashicorp/aws"
      version = "<4.51.0"
    }
  }
}

provider "sysdig" {
  sysdig_secure_api_token = var.sysdig_secure_api_token
  sysdig_secure_url       = var.sysdig_secure_url
}

provider "aws" {
  region = var.region
}

module "cloudvision_aws_single_account_ecs" {
  source = "../../../examples/single-account-ecs"
  name   = "${var.name}-single"

  deploy_image_scanning_ecr = true
  deploy_image_scanning_ecs = true

  enable_autoscaling = true
  min_replicas       = 2
  max_replicas       = 4
}
