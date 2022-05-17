# Sysdig Secure for Cloud in AWS

Terraform module that deploys the [**Sysdig Secure for Cloud** stack in **AWS**](https://docs.sysdig.com/en/docs/installation/sysdig-secure-for-cloud/deploy-sysdig-secure-for-cloud-on-aws).
<br/>

Provides unified threat-detection, compliance, forensics and analysis through these major components:

* **[Threat Detection](https://docs.sysdig.com/en/docs/sysdig-secure/insights/)**: Tracks abnormal and suspicious activities in your cloud environment based on Falco language. Managed through `cloud-connector` module. <br/>

* **[Compliance](https://docs.sysdig.com/en/docs/sysdig-secure/posture/compliance/compliance-unified-/)**: Enables the evaluation of standard compliance frameworks. Requires both modules  `cloud-connector` and `cloud-bench`. <br/>

* **[Identity and Access Management](https://docs.sysdig.com/en/docs/sysdig-secure/posture/permissions-and-entitlements/)**: Analyses user access overly permissive policies. Requires both modules  `cloud-connector` and `cloud-bench`. <br/>

* **[Image Scanning](https://docs.sysdig.com/en/docs/sysdig-secure/scanning/)**: Automatically scans all container images pushed to the registry (ECR) and the images that run on the AWS workload (currently ECS). Managed through `cloud-connector`. <br/>Disabled by Default, can be enabled through `deploy_image_scanning_ecr` and `deploy_image_scanning_ecs` input variable parameters.<br/>

For other Cloud providers check: [GCP](https://github.com/sysdiglabs/terraform-google-secure-for-cloud), [Azure](https://github.com/sysdiglabs/terraform-azurerm-secure-for-cloud)

<br/>

[comment]: <> (## Permissions)

[comment]: <> (Inspect `/module/infrastructure/permissions` subdirectories to understand the several)

[comment]: <> (permissions required.)

[comment]: <> (- `/iam-user` creates an IAM user + adds permissions for required modules &#40;general, cloud-connector, cloud-scanning&#41;<br/><br/>)

[comment]: <> (- `/general` concerns general permissions that apply to both threat-detection and image-scanning features)

[comment]: <> (- `/cloud-connector` for threat-detection features)

[comment]: <> (- `/cloud-scanning` for image-scanning features)

[comment]: <> (TODO review `/module/*/ permissions` vs. the ones in permissions folder)

[comment]: <> (TODO review)

[comment]: <> (- `/org-role-ecs`)

[comment]: <> (- `/org-role-eks`)


### Notice

* **Resource creation inventory** Find all the resources created by Sysdig examples in the resource-group `sysdig-secure-for-cloud` (AWS Resource Group & Tag Editor) <br/><br/>
* **Deployment cost** This example will create resources that cost money.<br/>Run `terraform destroy` when you don't need them anymore

<br/>


## Usage

  - There are several ways to deploy this in you AWS infrastructure, gathered under **[`/examples`](./examples)**
    - [Single Account on ECS](#--single-account-on-ecs)
    - [Single Account on AppRunner](#--single-account-on-apprunner)
    - [Single-Account with a pre-existing Kubernetes Cluster](#--single-account-with-a-pre-existing-kubernetes-cluster)
    - [Organizational](#--organizational)
  - Many module,examples and use-cases provide ways to **re-use existing resources (as optionals)** in your infrastructure (cloudtrail, ecs, vpc, k8s cluster,...)
  - Find some real self-baked **use-case scenarios** under [`/use-cases`](./use-cases)

### - Single-Account on ECS

Sysdig workload will be deployed in the same account where user's resources will be watched.<br/>
More info in [`./examples/single-account-ecs`](https://github.com/sysdiglabs/terraform-aws-secure-for-cloud/tree/master/examples/single-account-ecs)

![single-account diagram](https://raw.githubusercontent.com/sysdiglabs/terraform-aws-secure-for-cloud/master/examples/single-account-ecs/diagram-single.png)

### - Single-Account on AppRunner

Sysdig workload will be deployed using AppRunner in the same account where user's resources will be watched.<br/>
More info in [`./examples/single-account-apprunner`](https://github.com/sysdiglabs/terraform-aws-secure-for-cloud/tree/master/examples/single-account-apprunner)

![single-account diagram on apprunner](https://raw.githubusercontent.com/sysdiglabs/terraform-aws-secure-for-cloud/master/examples/single-account-apprunner/diagram-single.png)

### - Single-Account with a pre-existing Kubernetes Cluster

If you already own a Kubernetes Cluster on AWS, you can use it to deploy Sysdig Secure for Cloud, instead of default ECS cluster.<br/>
More info in [`./examples/single-account-k8s`](https://github.com/sysdiglabs/terraform-aws-secure-for-cloud/tree/master/examples/single-account-k8s)

![single-account with pre-existing kubernetes cluster](https://raw.githubusercontent.com/sysdiglabs/terraform-aws-secure-for-cloud/master/examples/single-account-k8s/diagram.png)

### - Organizational

Using an organizational configuration Cloudtrail.<br/>
More info in [`./examples/organizational`](https://github.com/sysdiglabs/terraform-aws-secure-for-cloud/tree/master/examples/organizational)

![organizational diagram](https://raw.githubusercontent.com/sysdiglabs/terraform-aws-secure-for-cloud/master/examples/organizational/diagram-org.png)

### - Self-Baked

If no [examples](https://github.com/sysdiglabs/terraform-aws-secure-for-cloud/tree/master/examples) fit your use-case, be free to call desired modules directly.

In this use-case we will ONLY deploy cloud-bench, into the target account, calling modules directly.

```terraform
terraform {
  required_providers {
    aws = {}
    sysdig = {
      source  = "sysdiglabs/sysdig"
    }
  }
}

provider "aws" {
  region = "AWS-REGION"
}

provider "sysdig" {
  sysdig_secure_url         = "<SYSDIG_SECURE_URL>"
  sysdig_secure_api_token   = "<SYSDIG_SECURE_API_TOKEN>"
}

module "cloud_bench" {
  source      = "sysdiglabs/secure-for-cloud/aws//modules/services/cloud-bench"
}

```
See [inputs summary](#inputs) or main [module `variables.tf`](https://github.com/sysdiglabs/terraform-aws-secure-for-cloud/tree/master/variables.tf) file for more optional configuration.

To run this example you need have your [aws master-account profile configured in CLI](https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-profiles.html) and to execute:
```terraform
$ terraform init
$ terraform plan
$ terraform apply
```

## Required Permissions

### Provisioning Permissions

Terraform provider credentials/token, requires `Administrative` permissions in order to be able to create the
resources specified in the per-example diagram.

Some components may vary, and you can check full resources on each module "Resources" section in their README's, but this would be an overall schema of the **created resources**:

- SSM Parameter for Sysdig API Token Storage
- Cloudtrail / SNS / S3 / SQS

- Sysdig Workload: ECS / AppRunner creation (EKS is pre-required, not created)
  - each compute solution require a role to assume for execution

- CodeBuild for on-demand image scanning
- Role for Sysdig [Benchmarks](./modules/services/cloud-bench)

### Runtime Permissions

Modules create several roles to be able to manage the following permissions.

**General  Permissions**

```shell
ssm: GetParameters

sqs: ReceiveMessage
sqs: DeleteMessage

s3: ListBucket
s3: GetObject
```

**Image-Scanning specific**

```shell
codebuild: StartBuild

ecr: GetAuthorizationToken
ecr: BatchCheckLayerAvailability
ecr: GetDownloadUrlForLayer
ecr: GetRepositoryPolicy
ecr: DescribeRepositories
ecr: ListImages
ecr: DescribeImages
ecr: BatchGetImage
ecr: GetLifecyclePolicy
ecr: GetLifecyclePolicyPreview
ecr: ListTagsForResource
ecr: DescribeImageScanFindings

ecs:DescribeTaskDefinition

```

Notes:
- only Sysdig workload related permissions are specified above; infrastructure internal resource permissions (such as Cloudtrail permissions to publish on SNS, or SNS-SQS Subscription)
are not detailed.
- For a better security, permissions are resource pinned, instead of `*`
- Check [Organizational Use Case - Role Summary](./examples/organizational/README.md#role-summary) for more details


## Forcing Events

**Threat Detection**

Terraform example module to trigger **Create IAM Policy that Allows All** event can be found on [examples/trigger-events](https://github.com/sysdiglabs/terraform-aws-secure-for-cloud/blob/master/examples/trigger-events).

In another case, you can do it manually. Choose one of the rules contained in the `AWS Best Practices` policy and execute it in your AWS account.

ex.: 'Delete Bucket Public Access Block' can be easily tested going to an
`S3 bucket > Permissions > Block public access (bucket settings) > edit >
uncheck 'Block all public access'`

Remember that in case you add new rules to the policy you need to give it time to propagate the changes.

In the `cloud-connector` logs you should see similar logs to these
> A public access block for a bucket has been deleted (requesting  user=OrganizationAccountAccessRole, requesting IP=x.x.x.x, AWS  region=eu-central-1, bucket=***

If that's not working as expected, some other questions can be checked
- are events consumed in the sqs queue, or are they pending?
- are events being sent to sns topic?

**Image Scanning**

  - For ECR image scanning, upload any image to an ECR repository of AWS. Can find CLI instructions within the UI of AWS
  - For ECS running image scanning, deploy any task in your own cluster, or the one that we create to deploy our workload (ex.`amazon/amazon-ecs-sample` image).

It may take some time, but you should see logs detecting the new image in the ECS cloud-connector task and a CodeBuild project being launched successfully

<br/><br/>

## Troubleshooting

## Q-Debug: Need to troubleshoot cloud-connector with `debug` loglevel
A: both in ECS and AppRunner workload types, cloud-connector configuration is passed as a base64-encoded string through the env var `CONFIG`
<br/>S: Get current value, decode it, edit the desired `logging: debug` value, encode it again, and spin it again with this new definition.

### Q-General: Getting error "Error: cannot verify credentials" on "sysdig_secure_trusted_cloud_identity" data
A: This happens when Sysdig credentials are not working correctly.
<br/>S: Check sysdig provider block is correctly configured with the `sysdig_secure_url` and `sysdig_secure_api_token` variables
with the correct values. Check [Sysdig SaaS per-region URLs if required](https://docs.sysdig.com/en/docs/administration/saas-regions-and-ip-ranges)

### Q-General: I'm not able to see Cloud Infrastructure Entitlements Management (CIEM) results
A: Make sure you installed both [cloud-bench](https://github.com/sysdiglabs/terraform-aws-secure-for-cloud/tree/master/modules/services/cloud-bench) and [cloud-connector](https://github.com/sysdiglabs/terraform-aws-secure-for-cloud/tree/master/modules/services/cloud-connector) modules


### Q-AWS: Getting error "Error: failed creating ECS Task Definition: ClientException: No Fargate configuration exists for given values.
A: Your ECS task_size values aren't valid for Fargate. Specifically, your mem_limit value is too big for the cpu_limit you specified
<br/>S: Check [supported task cpu and memory values](https://docs.aws.amazon.com/AmazonECS/latest/developerguide/task-cpu-memory-error.html)

### Q-AWS: Getting error "404 Invalid parameter: TopicArn" when trying to reuse an existing cloudtrail-sns

```text
│ Error: error creating SNS Topic Subscription: InvalidParameter: Invalid parameter: TopicArn
│ 	status code: 400, request id: 1fe94ceb-9f58-5d39-a4df-169f55d25eba
│
│   with module.cloudvision_aws_single_account.module.cloud_connector.module.cloud_connector_sqs.aws_sns_topic_subscription.this,
│   on ../../../modules/infrastructure/sqs-sns-subscription/main.tf line 6, in resource "aws_sns_topic_subscription" "this":
│    6: resource "aws_sns_topic_subscription" "this" {

```

A: In order to subscribe to a SNS Topic, SQS queue must be in the same region
<br/>S: Change `aws provider` `region` variable to match same region for all resources

### Q-AWS: Getting error "400 availabilityZoneId is invalid" when creating the ECS subnet
```text
│ Error: error creating subnet: InvalidParameterValue: Value (apne1-az3) for parameter availabilityZoneId is invalid. Subnets can currently only be created in the following availability zones: apne1-az1, apne1-az2, apne1-az4.
│ 	status code: 400, request id: 6e32d757-2e61-4220-8106-22ccf814e1fe
│
│   with module.vpc.aws_subnet.public[1],
│   on .terraform/modules/vpc/main.tf line 376, in resource "aws_subnet" "public":
│  376: resource "aws_subnet" "public" {
```

A: For the ECS workload deployment a VPC is being created under the hood. Some AWS zones, such as the 'apne1-az3' in the 'ap-northeast' region does not support NATS, which is activated by default.
<br/>S: Specify the desired VPC region availability zones for the vpc module, using the `ecs_vpc_region_azs` variable to explicit its desired value and workaround the error until AWS gives support for your region.


### Q-AWS: I get 400 api error AuthorizationHeaderMalformed on the Sysdig workload ECS Task

```text
error while receiving the messages: error retrieving from S3 bucket=crit-start-trail: operation error S3: GetObject,
https response error StatusCode: 400, RequestID: ***, HostID: ***,
api error AuthorizationHeaderMalformed: The authorization header is malformed; a non-empty Access Key (AKID) must be provided in the credential."}
```
A: When the S3 bucket, where cloudtrail events are stored, is not in the same account as where the Cloud Connector workload is deployed, it requires the
use of the [`assumeRole` configuration](https://github.com/sysdiglabs/terraform-aws-secure-for-cloud/blob/master/modules/services/cloud-connector/s3-config.tf#L30).
This error happens when the ECS `TaskRole` has no permissions to assume this role
<br/>S: Give permissions to `sts:AssumeRole` to the role used.


### Q-AWS: Getting error 409 `EntityAlreadyExists`

A: Probably you or someone in the same environment you're using, already deployed a resource with the sysdig terraform module and a naming collision is happening.
<br/>S: If you want to maintain several versions, make use of the [`name` input var of the examples](https://github.com/sysdiglabs/terraform-aws-secure-for-cloud/tree/master/examples/single-account#input_name)

<br/><br/>
## Authors

Module is maintained and supported by [Sysdig](https://sysdig.com).

## License

Apache 2 Licensed. See LICENSE for full details.
