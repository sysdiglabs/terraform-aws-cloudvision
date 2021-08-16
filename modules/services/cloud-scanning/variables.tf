variable "ecs_cluster" {
  type        = string
  description = "ECS Fargate Cluster where deploy the CloudConnector workload"
}

variable "build_project_arn" {
  type        = string
  description = "Code Build project arn"
}

variable "build_project_name" {
  type        = string
  description = "Code Build project name"
}


#---------------------------------
# vpc
#---------------------------------
variable "vpc_id" {
  type        = string
  description = "VPC where the workload is deployed"
}

variable "vpc_subnets" {
  type        = list(string)
  description = "Subnets where the CloudScanning will be deployed"
}

variable "secure_api_token_secret_name" {
  type        = string
  description = "Sysdig Secure API Token secret name"
}

#---------------------------------
# cloud-scanning parametrization
#---------------------------------

variable "sns_topic_arn" {
  type        = string
  description = "CloudTrail module created SNS Topic ARN"
}


#---------------------------------
# optionals - with default
#---------------------------------

variable "sysdig_secure_endpoint" {
  type        = string
  default     = "https://secure.sysdig.com"
  description = "Sysdig Secure API endpoint"
}

variable "name" {
  type        = string
  default     = "cloud-scanning"
  description = "Name for the Cloud Scanning deployment"
}

variable "image" {
  type = string
  # FIXME: rollback to latest
  default     = "sysdiglabs/cloud-scanning:master"
  description = "Image of the cloud scanning to deploy"
}

variable "cloudwatch_log_retention" {
  type        = number
  default     = 5
  description = "Days to keep logs for CloudScanning"
}

variable "tags" {
  type        = map(string)
  description = "sysdig cloudvision tags"
  default = {
    "product" = "sysdig-cloudvision"
  }
}

variable "verify_ssl" {
  type        = bool
  default     = true
  description = "true/false to determine ssl verification"
}

variable "extra_env_vars" {
  type        = map(string)
  default     = {}
  description = "Extra environment variables for the Cloud Scanning deployment"
}
