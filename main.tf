data "template_file" "bootstrap" {
  template = "${file("${path.module}/templates/bootstrap.sh.tpl")}"
  vars {
    hostname = "${var.host_prefix}-${var.hostname}.${var.internal_domain_name}"
    puppet_server = "${var.host_prefix}-foreman-01.${var.internal_domain_name}"
    puppet_env = "production"
    role = "jumphost"
  }
}

#data "template_cloudinit_config" "jumphost-01" {
#  part {
#    filename = "bootstrap.sh"
#    content_type = "text/x-shellscript"
#    content = "${data.template_file.bootstrap-jumphost-01.rendered}"
#  }
#  part {
#    filename = "reboot.sh"
#    content_type = "text/x-shellscript"
#    content = "${file("${path.module}/templates/reboot.sh")}"
#  }
#}

#resource "aws_instance" "jumphost-01" {
#    ami = "${lookup(var.amis, var.aws_region)}"
#    availability_zone = "us-east-2a"
#    instance_type = "t2.micro"
#    key_name = "${var.aws_key_name}"
#    vpc_security_group_ids = ["${aws_security_group.general.id}", "${aws_security_group.ssh_jump.id}"]
#    subnet_id = "${aws_subnet.us-east-2a-dmz.id}"
#    user_data = "${data.template_cloudinit_config.jumphost-01.rendered}"
#    iam_instance_profile = "${var.iam_instance_profile}"
#    lifecycle {
#      ignore_changes = ["user_data"]
#    }
#    tags {
#        Name = "${var.host_prefix}-jumphost-01"
#    }
#}

#resource "aws_route53_record" "jumphost-01" {
#  zone_id = "${aws_route53_zone.internal.id}"
#  name    = "${aws_instance.jumphost-01.tags.Name}"
#  type    = "A"
#  ttl     = "300"
#  records = ["${aws_instance.jumphost-01.private_ip}"]
#}

#output "jumphost-01" {
#  value = "${aws_route53_record.jumphost-01.name} (${aws_instance.jumphost-01.private_ip})\t[${aws_eip.jumphost-01.public_ip}]"
#}

# External DNS
#resource "aws_eip" "jumphost-01" {
#    instance = "${aws_instance.jumphost-01.id}"
#    vpc = true
#}

#resource "aws_route53_record" "jumphost-01-ext" {
#  count = "${var.external_dns_enable}"
#  zone_id = "${aws_route53_zone.external.id}"
#  name    = "${aws_instance.jumphost-01.tags.Name}"
#  type    = "A"
#  ttl     = "300"
#  records = ["${aws_eip.jumphost-01.public_ip}"]
#}

#output "jumphost-01-ext" {
#  value = "${aws_route53_record.jumphost-01-ext.fqdn} (${aws_eip.jumphost-01.public_ip})"
#}

# Special SSH Command for JumpHost
#output "jumphost-01-ssh-command" {
#  value = "ssh -A centos@${aws_eip.jumphost-01.public_ip} -L 9443:${aws_instance.gitlab-01.tags.Name}:443 -L 2222:${aws_instance.gitlab-01.tags.Name}:22 -L 8443:${aws_instance.foreman-01.tags.Name}:443 "
#}
