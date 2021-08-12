variable "ecs_cluster" {
  type        = string
  description = "ECS Fargate Cluster where deploy the CloudConnector workload"
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
  description = "Subnets where the CloudConnector will be deployed"
}


#---------------------------------
# cloud-connector parametrization
#---------------------------------

variable "sysdig_secure_api_token" {
  type        = string
  sensitive   = true
  description = "Sysdig Secure API token"
}

variable "sns_topic_arn" {
  type        = string
  description = "CloudTrail module created SNS Topic ARN"
}


#---------------------------------
# optionals - with default
#---------------------------------

#
# module composition
#

variable "is_organizational" {
  type        = bool
  default     = false
  description = "whether cloudvision should be deployed in an organizational setup"
}


variable "oragnizational_config" {
  type = object({
    cloudvision_role_arn         = string
    connector_ecs_task_role_name = string
  })
  default = {
    cloudvision_role_arn         = null
    connector_ecs_task_role_name = null
  }

  description = <<-EOT
    oragnizational_config. following attributes must be given
    <ul><li>`cloudvision_role_arn` for cloud-connect assumeRole in order to read cloudtrail s3 events</li><li>and the `connector_ecs_task_role_name` which has been granted trusted-relationship over the cloudvision_role</li></ul>
  EOT
}

#
# module config
#

variable "connector_ecs_task_role_name" {
  type        = string
  default     = "connector-ECSTaskRole"
  description = "Default ecs cloudconnector task role name"
}

variable "image" {
  type        = string
  default     = "sysdiglabs/cloud-connector:latest"
  description = "Image of the cloud connector to deploy"
}

variable "cloudwatch_log_retention" {
  type        = number
  default     = 5
  description = "Days to keep logs for CloudConnector"
}

variable "verify_ssl" {
  type        = bool
  default     = true
  description = "true/false to determine ssl verification for sysdig_secure_endpoint"
}

variable "extra_env_vars" {
  type        = map(string)
  default     = {}
  description = "Extra environment variables for the Cloud Connector deployment"
}

#
# misc
#
variable "sysdig_secure_endpoint" {
  type        = string
  default     = "https://secure.sysdig.com"
  description = "Sysdig Secure API endpoint"
}

variable "name" {
  type        = string
  default     = "connector"
  description = "Name for the Cloud Connector deployment"
}

variable "tags" {
  type        = map(string)
  description = "sysdig cloudvision tags"
  default = {
    "product" = "sysdig-cloudvision"
  }
}
