# Sysdig Secure for Cloud in AWS<br/>[ Example :: Single-Account ]

Deploy Sysdig Secure for Cloud in a single AWS account.<br/>
All the required resources and workloads will be run under the same account.

![single-account diagram](https://raw.githubusercontent.com/sysdiglabs/terraform-aws-secure-for-cloud/7d142829a701ce78f13691a4af4be373625e7ee2/examples/single-account/diagram-single.png)

## Prerequisites

Minimum requirements:

1. Configure [Terraform **AWS** Provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
1. Secure requirements, as input variable value
    ```
    sysdig_secure_api_token=<SECURE_API_TOKEN>
    ```

## Usage

For quick testing, use this snippet on your terraform files

```terraform
provider "aws" {
   region = "<AWS-REGION>; ex. us-east-1"
}

module "secure_for_cloud_aws_single_account" {
  source = "sysdiglabs/secure-for-cloud/aws//examples/single-account"

  sysdig_secure_api_token = "00000000-1111-2222-3333-444444444444"
}
```

See [inputs summary](#inputs) or module module [`variables.tf`](https://github.com/sysdiglabs/terraform-aws-secure-for-cloud/blob/master/examples/single-account/variables.tf) file for more optional configuration.

To run this example you need have your [aws account profile configured in CLI](https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-profiles.html) and to execute:
```terraform
$ terraform init
$ terraform plan
$ terraform apply
```

Notice that:
* This example will create resources that cost money.<br/>Run `terraform destroy` when you don't need them anymore
* All created resources will be created within the tags `product:sysdig-secure-for-cloud`, within the resource-group `sysdig-secure-for-cloud`

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 0.15.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 3.62.0 |
| <a name="requirement_sysdig"></a> [sysdig](#requirement\_sysdig) | >= 0.5.21 |

## Providers

No providers.

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_cloud_bench"></a> [cloud\_bench](#module\_cloud\_bench) | ../../modules/services/cloud-bench | n/a |
| <a name="module_cloud_connector"></a> [cloud\_connector](#module\_cloud\_connector) | ../../modules/services/cloud-connector | n/a |
| <a name="module_cloudtrail"></a> [cloudtrail](#module\_cloudtrail) | ../../modules/infrastructure/cloudtrail | n/a |
| <a name="module_codebuild"></a> [codebuild](#module\_codebuild) | ../../modules/infrastructure/codebuild | n/a |
| <a name="module_ecs_vpc_secgroup"></a> [ecs\_vpc\_secgroup](#module\_ecs\_vpc\_secgroup) | ../../modules/infrastructure/ecs-vpc | n/a |
| <a name="module_resource_group"></a> [resource\_group](#module\_resource\_group) | ../../modules/infrastructure/resource-group | n/a |
| <a name="module_ssm"></a> [ssm](#module\_ssm) | ../../modules/infrastructure/ssm | n/a |

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_sysdig_secure_api_token"></a> [sysdig\_secure\_api\_token](#input\_sysdig\_secure\_api\_token) | Sysdig Secure API token | `string` | n/a | yes |
| <a name="input_benchmark_regions"></a> [benchmark\_regions](#input\_benchmark\_regions) | List of regions in which to run the benchmark. If empty, the task will contain all aws regions by default. | `list(string)` | `[]` | no |
| <a name="input_cloudtrail_is_multi_region_trail"></a> [cloudtrail\_is\_multi\_region\_trail](#input\_cloudtrail\_is\_multi\_region\_trail) | true/false whether cloudtrail will ingest multiregional events | `bool` | `true` | no |
| <a name="input_cloudtrail_kms_enable"></a> [cloudtrail\_kms\_enable](#input\_cloudtrail\_kms\_enable) | true/false whether cloudtrail delivered events to S3 should persist encrypted | `bool` | `true` | no |
| <a name="input_cloudtrail_sns_arn"></a> [cloudtrail\_sns\_arn](#input\_cloudtrail\_sns\_arn) | ARN of a pre-existing cloudtrail\_sns. If defaulted, a new cloudtrail will be created | `string` | `"create"` | no |
| <a name="input_deploy_benchmark"></a> [deploy\_benchmark](#input\_deploy\_benchmark) | Whether to deploy or not the cloud benchmarking | `bool` | `true` | no |
| <a name="input_ecs_cluster_name"></a> [ecs\_cluster\_name](#input\_ecs\_cluster\_name) | Name of a pre-existing ECS (elastic container service) cluster. If defaulted, a new ECS cluster/VPC/Security Group will be created | `string` | `"create"` | no |
| <a name="input_ecs_vpc_id"></a> [ecs\_vpc\_id](#input\_ecs\_vpc\_id) | ID of the VPC where the workload is to be deployed. Defaulted to be created when 'ecs\_cluster\_name' is not provided. | `string` | `"create"` | no |
| <a name="input_ecs_vpc_region_azs"></a> [ecs\_vpc\_region\_azs](#input\_ecs\_vpc\_region\_azs) | List of Availability Zones for ECS VPC creation. e.g.: ["apne1-az1", "apne1-az2"]. If defaulted, two of the default 'aws\_availability\_zones' datasource will be taken | `list(string)` | `[]` | no |
| <a name="input_ecs_vpc_subnets_private_ids"></a> [ecs\_vpc\_subnets\_private\_ids](#input\_ecs\_vpc\_subnets\_private\_ids) | List of VPC subnets where workload is to be deployed. Defaulted to be created when 'ecs\_cluster\_name' is not provided. | `list(string)` | `[]` | no |
| <a name="input_name"></a> [name](#input\_name) | Name to be assigned to all child resources. A suffix may be added internally when required. Use default value unless you need to install multiple instances | `string` | `"sfc"` | no |
| <a name="input_sysdig_secure_endpoint"></a> [sysdig\_secure\_endpoint](#input\_sysdig\_secure\_endpoint) | Sysdig Secure API endpoint | `string` | `"https://secure.sysdig.com"` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | sysdig secure-for-cloud tags | `map(string)` | <pre>{<br>  "product": "sysdig-secure-for-cloud"<br>}</pre> | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_cloudtrail_sns_topic_arn"></a> [cloudtrail\_sns\_topic\_arn](#output\_cloudtrail\_sns\_topic\_arn) | ARN of cloudtrail\_sns topic |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->


## Authors

Module is maintained and supported by [Sysdig](https://sysdig.com).

## License

Apache 2 Licensed. See LICENSE for full details.
