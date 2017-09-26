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

variable "centos-amis"{ # Centos 7
    description = "AMIs by region"
    default = {
        us-east-2 = "ami-6a2d760f"
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

variable "general_id" {
  description = "SSH Public Key Name in AWS"
}

variable "general_id" {
  description = "SSH Public Key Name in AWS"
}

variable "subnet_id" {
  description = "SSH Public Key Name in AWS"
}
