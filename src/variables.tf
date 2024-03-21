variable "aws_region" {
  default = "eu-west-1"
  description = "AWS Region where to install resources"
}
##################################
## Consule cluster configuration
##################################

# See https://github.com/hashicorp/terraform-aws-nomad/tree/master

variable "consul_cluster_size" {
  default = 1
  description = "consul cluster sizer"
}

variable "consul_cluster_name" {
  description = "consul cluster sizer"
}

variable "consul_cluster_instance_type" {
  description = "What kind of instance type to use for the nomad clients"
  type        = string
  default     = "t2.micro"
}

variable "consul_cluster_tag_key" {
  description = "The tag the EC2 Instances will look for to automatically discover each other and form a cluster."
  type        = string
  default     = "nomad-servers"
}


variable "consul_cluster_tag_value" {
  description = "Add a tag with key var.cluster_tag_key and this value to each Instance in the ASG. This can be used to automatically find other Consul nodes and form a cluster."
  type        = string
  default     = "auto-join"
}

variable "consul_cluster_ssh_key_name" {
  description = "The name of an EC2 Key Pair that can be used to SSH to the EC2 Instances in this cluster. Set to an empty string to not associate a Key Pair."
  type        = string
  default     = ""
}


variable "consul_cluster_vpc_id" {
  description = "The ID of the VPC in which the nodes will be deployed.  Uses default VPC if not supplied."
  type        = string
  default     = ""
}
