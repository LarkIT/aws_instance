variable "region" {
  description = "The AWS region."
}

variable "hostname" {
  description = "The AWS hostname assigned to the server."
}

variable "host_prefix" {
  description = "Hostname prefix (abc)"
}

variable "internal_domain_name" {
  description = "Hostname prefix (abc)"
}

variable "bootscript_script" {
  description = "Shell script to bootstrap the system."
  default     = "bootstrap.sh"
}

variable "reboot_script" {
  description = "Shell script to reboot the system."
  default     = "reboot.sh"
}

variable "instance_type" {
  description = "Virtual machine tshirt size"
  default     = "t2.micro"
}

variable "ami" {
  description = "Virtual machine aws ami"
  default     = "ami-f5d7f195"
}

variable "centos7-ami"{
  description = "AMIs by region"
  default = {
    us-east-1 = "ami-46c1b650"
    us-east-2 = "ami-18f8df7d"
    us-west-1 = "ami-f5d7f195"
    us-west-2 = "ami-f4533694"
  }
}

variable "availability_zone" {
  description = "VPC network availability zone"
  default     = "a"
}

variable "aws_key_name" {
  description = "SSH Public Key Name in AWS"
  default = "lark-provisioning"
}

variable "security_groups" {
  description = "SSH Public Key Name in AWS"
  type        = "list"
}

variable "subnet_id" {
  description = "SSH Public Key Name in AWS"
}

variable "iam_instance_profile" {
  description = "SSH Public Key Name in AWS"
  default     = "basicServer"
}

variable "route53_internal_id" {
  description = "SSH Public Key Name in AWS"
}

variable "route53_external_id" {
  description = "SSH Public Key Name in AWS"
  default     = ""
}

variable "external_dns_enable" {
  description = "Enable an external dns on hostname"
  default     = false
}

variable "external_hostname" {
  description = "Enable an external dns on hostname"
  default     = "aws.lark-it.com"
}

variable "number_of_instances" {
  description = "Number of virutal machines to create."
  default     = "1"
}

variable "role" {
  description = "Puppet classification role"
  default     = "base"
}

#variable "bootstrap" {
#  description = "Puppet classification role"
#  default     = "${module.bootstrap.base_cloutinit}"
#}

variable "enable_aws_eip" {
  description = "External IP to connect to"
  default     = false
}

variable "enable_ebs_volume" {
  description = "Additional ebs volume"
  default     = false
}

variable "ebs_volume_size" {
  description = "Size of the ebs volume"
  default     = "50"
}

variable "device_name" {
  description = "The name of the ebs device"
  default     = "/dev/sdx"
}
