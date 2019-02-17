locals {
  unique_project_id   = "djr"
  ssh_key_name        = "vault-${local.unique_project_id}-ssh-key-name" # The name of an EC2 Key Pair that can be used to SSH to the EC2 Instances in this cluster. Set to an empty string to not associate a Key Pair.
  vault_cluster_name  = "vault-${local.unique_project_id}"
  consul_cluster_name = "consul-${local.unique_project_id}"
}

variable "ami_id" {
  description = "The ID of the AMI to run in the cluster. This should be an AMI built from the Packer template under examples/vault-consul-ami/vault-consul.json."
  default     = "ami-0d3b2cf862bc2d41b"                                                                                                                            # us-east-1
}

variable "vault_cluster_size" {
  description = "The number of Vault server nodes to deploy. We strongly recommend using 3 or 5."
  default     = 3
}

variable "consul_cluster_size" {
  description = "The number of Consul server nodes to deploy. We strongly recommend using 3 or 5."
  default     = 3
}

variable "vault_instance_type" {
  description = "The type of EC2 Instance to run in the Vault ASG"
  default     = "t2.micro"
}

variable "consul_instance_type" {
  description = "The type of EC2 Instance to run in the Consul ASG"
  default     = "t2.nano"
}

variable "consul_cluster_tag_key" {
  description = "The tag the Consul EC2 Instances will look for to automatically discover each other and form a cluster."
  default     = "consul-servers"
}

variable "vpc_id" {
  description = "The ID of the VPC to deploy into. Leave an empty string to use the Default VPC in this region."
  default     = ""
}

variable "s3_bucket_name" {
  description = "The name of the S3 bucket to create and use as a storage backend. Only used if 'enable_s3_backend' is set to true."
  default     = ""
}
