# Vault AWS Module

This is a Terraform module for provisioning Vault with [integrated
storage](https://www.vaultproject.io/docs/concepts/integrated-storage) on AWS.
This module defaults to setting up a cluster with 5 Vault nodes (as recommended
by the [Vault with Integrated Storage Reference
Architecture](https://learn.hashicorp.com/vault/operations/raft-reference-architecture)).

## About This Module
This module implements the [Vault with Integrated Storage Reference
Architecture](https://learn.hashicorp.com/vault/operations/raft-reference-architecture#node)
on AWS using the open source version of Vault 1.8+.

## How to Use This Module

- Ensure your AWS credentials are [configured
  correctly](https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-files.html)
  and have permission to use the following AWS services:
    - Amazon Certificate Manager (ACM)
    - Amazon EC2
    - Amazon Elastic Load Balancing (ALB)
    - AWS Identity & Access Management (IAM)
    - AWS Key Management System (KMS)
    - Amazon Secrets Manager
    - AWS Systems Manager Session Manager (optional - used to connect to EC2
      instances with session manager using the AWS CLI)
    - Amazon VPC

- This module assumes you have an existing VPC along with an AWS secrets manager
  that contains TLS certs for the Vault nodes and load balancer. If you do not,
  you may use the following
  [quickstart](https://github.com/hashicorp/terraform-aws-vault-starter/tree/main/examples/prereqs_quickstart)
  to deploy these resources.

- To deploy into an existing VPC, ensure the following components exist and are
  routed to each other correctly:
  - Three public subnets
  - Three [NAT
    gateways](https://docs.aws.amazon.com/vpc/latest/userguide/vpc-nat-gateway.html) (one in each public subnet)
  - Three private subnets

- In this forked repo you will find a terraform.tfvars file that can be populated with the desired variables: 

```
# The region you wish to deploy into
aws_region                = "desired-region"
# Internal IP range including your jump host for allowing inbound ssh
allowed_inbound_cidrs_ssh = [
    "10.x.x.x/24",
]
# Instance type to use for vault instances
instance_type             = "t3.small"
# Name of the EC2 ssh key used to connect to your instances
key_name                  = "test-ec2-ssh-key"
# Duration in days after which the key is deleted after destruction of the resource (must be between 7 and 30 days)
kms_key_deletion_window   = 7
# AWS Secrets Manager ARN where TLS certs are stored
secrets_manager_arn       = "arn:aws:secretsmanager:region:account:secret:test-tls-secret-123"
# The shared DNS SAN of the TLS certs being used
leader_tls_servername     = "vault.server.com"
# The cert ARN to be used on the Vault LB listener
lb_certificate_arn        = "arn:aws:acm:region:account:certificate/123-456-789"
# Amount time, in seconds, for Vault LB target group to wait before changing the state of a deregistering target from draining to unused
lb_deregistration_delay   = 300
# The endpoint to check for Vault's health status
lb_health_check_path      = "/v1/sys/health?activecode=200&standbycode=200&sealedcode=200&uninitcode=200"
# Number of Vault nodes to deploy in ASG
node_count                = 5
# List of Subnet IDs to deploy Vault into
private_subnet_ids        = [
    "subnet-123",
    "subnet-456",
    "subnet-789",
]
# Prefix for tagging/naming AWS resources
resource_name_prefix      = "test"
# VPC ID you wish to deploy into
vpc_id                    = "vpc-123456789"
# The Version of Vault you wish to use
vault_version             = "1.11.0"
```

- Run `terraform init` and `terraform apply --var-file=terraform.tfvars`

- You must
  [initialize](https://www.vaultproject.io/docs/commands/operator/init#operator-init)
  your Vault cluster after you create it. Begin by logging into your Vault
  cluster using one of the following methods:
    - Using [Session
      Manager](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/session-manager.html)
    - SSH (you must provide the optional SSH key pair through the `key_name`
      variable and set a value for the `allowed_inbound_cidrs_ssh` variable.
        - Please note this Vault cluster is not public-facing. If you want to
          use SSH from outside the VPC, you are required to establish your own
          connection to it (VPN, etc).

**Please Note**: if you are using Session Manager to connect to your nodes and
will run vault commands as the default `ssm-user`, it is important you first run
the following command to source the environment variables that Vault requires:

```
$ . /etc/profile
```

  - To initialize the Vault cluster, run the following commands:

```bash
vault operator init
```

  - This should return back the following output which includes the recovery
    keys and initial root token (omitted here):

```
...
Success! Vault is initialized
```

  - Please securely store the recovery keys and initial root token that Vault
    returns to you.
  - To check the status of your Vault cluster, export your Vault token and run
    the
    [list-peers](https://www.vaultproject.io/docs/commands/operator/raft#list-peers)
    command:

```bash
export VAULT_TOKEN="<your Vault token>"
vault operator raft list-peers
```

- Please note that Vault does not enable [dead server
  cleanup](https://www.vaultproject.io/docs/concepts/integrated-storage/autopilot#dead-server-cleanup)
  by default. You must enable this to avoid manually managing the Raft
  configuration every time there is a change in the Vault ASG. To enable dead
  server cleanup, run the following command:

 ```bash
vault operator raft autopilot set-config \
    -cleanup-dead-servers=true \
    -dead-server-last-contact-threshold=10 \
    -min-quorum=3
 ```

- You can verify these settings after you apply them by running the following command:

```bash
vault operator raft autopilot get-config
```

## License

This code is released under the Mozilla Public License 2.0. Please see
[LICENSE](https://github.com/hashicorp/terraform-aws-vault-starter/blob/main/LICENSE)
for more details.
