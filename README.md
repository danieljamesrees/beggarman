# beggarman

When researching Secret Management tools, two types were identified:

1. Password Managers
2. Secret Secure Access Systems

The former tend to be UI-driven tools designed for individual users, while the later allow applications and computer systems to retrieve secrets for accessing other systems or components. This repository is concerned with the latter form of Secret Management tool.

## Password Managers

Prominent enterprise password management solutions include:

* [1Password](https://1password.com)
* [Keeper](https://keepersecurity.com)
* [LastPass](https://www.lastpass.com)
* [Secret Server](https://thycotic.com/products/secret-server/)
* [Zoho Vault](https://www.zoho.com/vault/)

## Secret Secure Access Systems

### Important Considerations

* Does the solution need to manage any secrets not being used by AWS?
* Do any compliance requirements mandate the use of a Hardware Security Module (HSM)?

### Primary Features

* Encrypt of data at rest and in transit.
* Auditing of access.
* Revocation and rotation of secrets.
* High Availability (mainly for applications exposed to consumers).

### Secondary Features

* Dynamic secret generation.
* Scalability.
* Leasing and renewing.

### AWS-specific Tools

AWS's own Secrets Management tools are [AWS Certificate Manager](https://aws.amazon.com/certificate-manager/) (ACM), [Identity and Access Management](https://aws.amazon.com/iam) (IAM), [Key Management Service](https://aws.amazon.com/kms/) (KMS), and [Secrets Manager](https://aws.amazon.com/secrets-manager/).

#### ACM

ACM is a service that permits easy provisioning, management, and deployment of Secure Sockets Layer/Transport Layer Security (SSL/TLS) certificates for use with AWS services and internal resources. There is no additional charge for provisioning public or private SSL/TLS certificates used with ACM-integrated services, such as Elastic Load Balancing and API Gateway. Creation and renewal of certificates can be automated when used with ACM-integrated services.

#### IAM

IAM enables management of access to AWS services and resources securely. Using IAM allows creation and management of AWS users and groups, and use of permissions to allow and deny their access to AWS resources. IAM is free of charge.

#### KMS

KMS is integrated with a [HSM](https://aws.amazon.com/cloudhsm) and complies with most security standards. As an internal solution, it works well with other AWS services. For example, all key usage is logged with CloudTrail, while authentication and authorization of key access can be managed using [Cognito](https://aws.amazon.com/cognito/). It supports easy rotation of keys and is API driven.

KMS costs US $1/month to store any key created. AWS managed keys created by AWS services are free to store, which may cover most Use Cases for enterprises, apart from any keys needed by non-AWS-native applications. You are charged per-request when you use or manage your keys beyond the free tier - the cost of these charges would need specific analysis to gauge.

#### Secrets Manager

AWS Secrets Manager enables easy rotation, management, and retrieval of database credentials, API keys, and other secrets throughout their lifecycle. Users and applications retrieve secrets with a call to Secrets Manager APIs, eliminating the need to hardcode sensitive information in plain text. Secrets Manager offers secret rotation with built-in integration for Amazon RDS for MySQL, PostgreSQL, and Amazon Aurora. Also, the service is extensible to other types of secrets, including API keys and OAuth tokens. In addition, Secrets Manager permits using fine-grained permissions plus centralised auditing and rotation for resources in the AWS Cloud, third-party services, and on-premises.

Using Secrets Manager, secrets can be encrypted with keys managed via KMS. With Secrets Manager, pricing is based on the number of secrets managed in Secrets Manager and the number of Secrets Manager API calls made.

No Jenkins plugins to use Secrets Manager has been found. Hence, it may be necessary to write a custom AWS API client ([see https://docs.aws.amazon.com/secretsmanager/latest/userguide/query-requests.html](https://docs.aws.amazon.com/secretsmanager/latest/userguide/query-requests.html)) or an SDK client ([see https://docs.aws.amazon.com/AWSJavaSDK/latest/javadoc/com/amazonaws/services/secretsmanager/package-summary.html](https://docs.aws.amazon.com/AWSJavaSDK/latest/javadoc/com/amazonaws/services/secretsmanager/package-summary.html)) whenever accessing AWS secrets. The [CloudBees AWS Credentials Plugin](https://wiki.jenkins.io/display/JENKINS/CloudBees+AWS+Credentials+Plugin) may be useful for invoking this code using Jenkins.

There is a [Terraform data source for accessing secrets](https://www.terraform.io/docs/providers/aws/d/secretsmanager_secret_version.html) and a [provider for rotating them](https://www.terraform.io/docs/providers/aws/r/secretsmanager_secret.html).

### Non-AWS-specific Tools

Prominent tools that can be used on all public clouds and on premise include:

* [HashiCorp Vault](https://www.hashicorp.com/products/vault/)

Not tied to any specific Configuration Management systems. For additional fault tolerance and scalability, Vault can be integrated with [Consul](https://github.com/hashicorp/consul).

Vault can be installed on AWS via [Terraform](https://github.com/hashicorp/terraform-aws-vault).

[The Vault Operator](https://coreos.com/blog/introducing-vault-operator-project) describes how to install Vault on Kubernetes. Information on installing Vault using Consul can be found at [https://github.com/drud/vault-consul-on-kube](https://github.com/drud/vault-consul-on-kube). Kubernetes has its own approach to [secret management](https://kubernetes.io/docs/concepts/configuration/secret/). However, using Vault as a stronger means of using secrets in Kubenetes is described at [https://banzaicloud.com/blog/inject-secrets-into-pods-vault/](https://banzaicloud.com/blog/inject-secrets-into-pods-vault/).

Jenkins can be integrated with Vault using the [https://wiki.jenkins.io/display/JENKINS/HashiCorp+Vault+Plugin](HashiCorp Vault plugin).

Jenkins-X is integrated with Vault. [Issue 703] (https://github.com/jenkins-x/jx/issues/703) describes how this was implemented and has a number of other useful links regarding cloud-based Vault installations.

There is also a [Terraform Vault provider](https://www.terraform.io/docs/providers/vault/index.html), though (as the docs note) `interacting with Vault from Terraform causes any secrets that you read and write to be persisted in both Terraform's state file and in any generated plan files`. Vault can be used to [implement dynamic secrets](https://www.hashicorp.com/resources/using-dynamic-secrets-in-terraform), while [Terraform Enterprise encrypts all variable values securely using Vault's transit backend prior to saving them](https://www.terraform.io/docs/enterprise/workspaces/variables.html#secure-storage-of-variables).

* [Key Whiz](https://square.github.io/keywhiz/)
* [Lockbox](https://github.com/starekrow/lockbox)
* [Dashlane](https://www.dashlane.com/)

## Building a Consul-based private Vault cluster using Terraform

To build a private Vault cluster based on Consul and using Terraform, run the script `setup_vault.sh` with the AWS credentials of an IAM user with the AmazonEC2FullAccess, IAMFullAccess, and AmazonS3FullAccess policies attached. The following script can be used as a wrapper:

```#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

export AWS_ACCESS_KEY_ID="USERS_ACCESS_KEY_ID"
export AWS_SECRET_ACCESS_KEY="USERS_SECRET_ACCESS_KEY"
export AWS_DEFAULT_REGION="us-east-1"

./setup_vault.sh
```

To check the code before committing, install the pre-commit git hook by running the commands `curl https://pre-commit.com/install-local.py | python -; pre-commit install` (on Ubuntu). The hook can be manually run using `pre-commit run --all` - it only works on staged or committed files. It requires installing shellcheck, which can be done on Ubuntu using `sudo apt-get install shellcheck`.

## TODOs

* Implement auto-unsealing.

## Useful Links

* [Comparing AWS Secrets Manager and Vault](https://www.reddit.com/r/devops/comments/8zmibk/aws_secrets_manager_vs_hashicorp_vault_what_can/)
* [The Right Way to Store Secrets](https://aws.amazon.com/blogs/mt/the-right-way-to-store-secrets-using-parameter-store/)
* [How are you managing application secrets on AWS?](https://www.reddit.com/r/devops/comments/8xa3u6/how_are_you_managing_application_secrets_on_aws/)
