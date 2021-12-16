# Sysdig Secure for Cloud in AWS

Terraform module that deploys the [**Sysdig Secure for Cloud** stack in **AWS**](https://docs.sysdig.com/en/docs/installation/sysdig-secure-for-cloud/deploy-sysdig-secure-for-cloud-on-aws).
<br/>

Provides unified threat-detection, compliance, forensics and analysis through these major components:

* **[CSPM/Compliance](https://docs.sysdig.com/en/docs/sysdig-secure/benchmarks/)**: It evaluates periodically your cloud configuration, using Cloud Custodian, against some benchmarks and returns the results and remediation you need to fix. Managed through `cloud-bench` module. <br/>

* **[CIEM](https://docs.sysdig.com/en/docs/sysdig-secure/posture/)**: Permissions and Entitlements management. Requires BOTH modules  `cloud-connector` and `cloud-bench`. <br/>

* **[Cloud Threat Detection](https://docs.sysdig.com/en/docs/sysdig-secure/insights/)**: Tracks abnormal and suspicious activities in your cloud environment based on Falco language. Managed through `cloud-connector` module. <br/>

* **[Cloud Scanning](https://docs.sysdig.com/en/docs/sysdig-secure/scanning/)**: Automatically scans all container images pushed to the registry or as soon a new task which involves a container is spawned in your account. Managed through `cloud-connector`. <br/>

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

## Usage

There are several ways to deploy this in you AWS infrastructure:

### - Single-Account

Sysdig workload will be deployed in the same account where user's resources will be watched.<br/>
More info in [`./examples/single-account`](https://github.com/sysdiglabs/terraform-aws-secure-for-cloud/tree/master/examples/single-account)

![single-account diagram](https://raw.githubusercontent.com/sysdiglabs/terraform-aws-secure-for-cloud/7d142829a701ce78f13691a4af4be373625e7ee2/examples/single-account/diagram-single.png)


### - Single-Account with a pre-existing Kubernetes Cluster

If you already own a Kubernetes Cluster on AWS, you can use it to deploy Sysdig Secure for Cloud, instead of default ECS cluster.<br/>
More info in [`./examples/single-account-k8s`](https://github.com/sysdiglabs/terraform-aws-secure-for-cloud/tree/master/examples/single-account-k8s)

### - Organizational

Using an organizational configuration Cloudtrail.<br/>
More info in [`./examples/organizational`](https://github.com/sysdiglabs/terraform-aws-secure-for-cloud/tree/master/examples/organizational)

![organizational diagram](https://raw.githubusercontent.com/sysdiglabs/terraform-aws-secure-for-cloud/5b7cf5e8028b3177536c9c847020ad6319342b44/examples/organizational/diagram-org.png)

### - Self-Baked

If no [examples](https://github.com/sysdiglabs/terraform-aws-secure-for-cloud/tree/master/examples) fit your use-case, be free to call desired modules directly.

In this use-case we will ONLY deploy cloud-bench, into the target account, calling modules directly

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
  sysdig_secure_api_token  = "00000000-1111-2222-3333-444444444444"
}

module "cloud_bench" {
  source      = "sysdiglabs/secure-for-cloud/aws//modules/cloud-bench"
}

```
See [inputs summary](#inputs) or main [module `variables.tf`](https://github.com/sysdiglabs/terraform-aws-secure-for-cloud/tree/master/variables.tf) file for more optional configuration.

To run this example you need have your [aws master-account profile configured in CLI](https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-profiles.html) and to execute:
```terraform
$ terraform init
$ terraform plan
$ terraform apply
```

Notice that:
* This example will create resources that cost money.<br/>Run `terraform destroy` when you don't need them anymore
* All created resources will be created within the tags `product:sysdig-secure-for-cloud`, within the resource-group `sysdig-secure-for-cloud`

<br/><br/>

## Forcing Events

**Threat Detection**

Choose one of the rules contained in the `AWS Best Practices` policy and execute it in your AWS account.

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

Upload any image to the ECR repository of AWS.
<br/>You should see a log in the ECS-cloud-scanner task + CodeBuild project being launched successfully

<br/><br/>
## Troubleshooting

### Q: I'm not able to see Cloud Infrastructure Entitlements Management (CIEM) results
A: Make sure you installed both [cloud-bench](https://github.com/sysdiglabs/terraform-aws-secure-for-cloud/tree/master/modules/services/cloud-bench) and [cloud-connector](https://github.com/sysdiglabs/terraform-aws-secure-for-cloud/tree/master/modules/services/cloud-connector) modules

### Q: How to iterate cloud-connector modification testing
A: Build a custom docker image of cloud-connector `docker build . -t <DOCKER_IMAGE> -f ./build/cloud-connector/Dockerfile` and upload it to any registry (like dockerhub).
Modify the [var.image](https://github.com/sysdiglabs/terraform-aws-secure-for-cloud/tree/master/modules/services/cloud-connector/variables.tf) variable to point to your image and deploy


### Q: How can I iterate ECS modification testing
A: After applying your modifications (vía terraform for example) restart the service
  ```
  $ aws ecs update-service --force-new-deployment --cluster sysdig-secure-for-cloud-ecscluster --service sysdig-secure-for-cloud-cloudconnector --profile <AWS_PROFILE>
  ```
For the AWS_PROFILE, set your `~/.aws/config` to impersonate
  ```
  [profile secure-for-cloud]
  region=eu-central-1
  role_arn=arn:aws:iam::<AWS_MANAGEMENT_ORGANIZATION_ACCOUNT>:role/OrganizationAccountAccessRole
  source_profile=<AWS_MANAGEMENT_ACCOUNT_PROFILE>
  ```

<br/><br/>
## Authors

Module is maintained and supported by [Sysdig](https://sysdig.com).

## License

Apache 2 Licensed. See LICENSE for full details.
