terraform {
  required_version = ">= 0.9.3"
}

module "vault_cluster" {
  source = "github.com/hashicorp/terraform-aws-vault//modules/vault-cluster?ref=v0.0.1"

  # Configure and start Vault during boot.
  user_data = <<-EOF
              #!/bin/bash
              /opt/vault/bin/run-vault --tls-cert-file /opt/vault/tls/vault.crt.pem --tls-key-file /opt/vault/tls/vault.key.pem
              EOF

  cluster_tag_key = "Name"
  cluster_name    = "${local.vault_cluster_name}"
  cluster_size    = "${var.vault_cluster_size}"

  ami_id         = "${var.ami_id}"
  s3_bucket_name = "${var.s3_bucket_name}"
  ssh_key_name   = "${local.ssh_key_name}"
  instance_type  = "${var.vault_instance_type}"

  subnet_ids = "${data.aws_subnet_ids.default.ids}"
  user_data  = "${data.template_file.user_data_vault_cluster.rendered}"
  vpc_id     = "${data.aws_vpc.default.id}"

  allowed_inbound_cidr_blocks        = ["0.0.0.0/0"]
  allowed_inbound_security_group_ids = []
  allowed_ssh_cidr_blocks            = ["0.0.0.0/0"]
}

module "consul_iam_policies_servers" {
  source = "github.com/hashicorp/terraform-aws-consul.git//modules/consul-iam-policies?ref=v0.4.0"

  iam_role_id = "${module.vault_cluster.iam_role_id}"
}

data "template_file" "user_data_vault_cluster" {
  template = "${file("${path.module}/user-data-vault.sh")}"

  vars {
    aws_region               = "${data.aws_region.current.name}"
    consul_cluster_tag_key   = "${var.consul_cluster_tag_key}"
    consul_cluster_tag_value = "${local.consul_cluster_name}"
  }
}

module "security_group_rules" {
  source = "github.com/hashicorp/terraform-aws-consul.git//modules/consul-client-security-group-rules?ref=v0.4.0"

  security_group_id = "${module.vault_cluster.security_group_id}"

  allowed_inbound_cidr_blocks = ["0.0.0.0/0"]
}

module "consul_cluster" {
  source = "github.com/hashicorp/terraform-aws-consul.git//modules/consul-cluster?ref=v0.4.0"

  cluster_name      = "${local.consul_cluster_name}"
  cluster_size      = "${var.consul_cluster_size}"
  cluster_tag_key   = "${var.consul_cluster_tag_key}"
  cluster_tag_value = "${local.consul_cluster_name}"

  ami_id        = "${var.ami_id}"
  instance_type = "${var.consul_instance_type}"
  ssh_key_name  = "${local.ssh_key_name}"

  user_data  = "${data.template_file.user_data_consul.rendered}"
  vpc_id     = "${data.aws_vpc.default.id}"
  subnet_ids = "${data.aws_subnet_ids.default.ids}"

  allowed_inbound_cidr_blocks = ["0.0.0.0/0"]
  allowed_ssh_cidr_blocks     = ["0.0.0.0/0"]
}

data "template_file" "user_data_consul" {
  template = "${file("${path.module}/user-data-consul.sh")}"

  vars {
    consul_cluster_tag_key   = "${var.consul_cluster_tag_key}"
    consul_cluster_tag_value = "${local.consul_cluster_name}"
  }
}

data "aws_vpc" "default" {
  default = "${var.vpc_id == "" ? true : false}"
  id      = "${var.vpc_id}"
}

data "aws_subnet_ids" "default" {
  vpc_id = "${data.aws_vpc.default.id}"
}

data "aws_region" "current" {}
