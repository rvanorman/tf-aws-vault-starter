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