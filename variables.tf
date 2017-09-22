variable "hostname" {
  description = "The AWS region."
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
}

