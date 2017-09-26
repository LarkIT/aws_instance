
resource "aws_instance" "hostname" {
    ami                    = "${var.ami}"
    availability_zone      = "${var.region}${var.availability_zone}"
    instance_type          = "${var.instance_type}"
    key_name               = "${var.aws_key_name}"
    vpc_security_group_ids = ["${var.general_id}" ]
    subnet_id              = "${var.subnet_id}"
    user_data              = "${data.template_cloudinit_config.hostname.rendered}"
    iam_instance_profile   = "${var.iam_instance_profile}"

    lifecycle {
      ignore_changes = ["user_data"]
    }

    tags {
        Name = "${var.host_prefix}-${var.hostname}"
    }
}

resource "aws_route53_record" "route53_record" {
  zone_id = "${var.route53_internal_id}"
  name    = "${aws_instance.hostname.tags.Name}"
  type    = "A"
  ttl     = "300"
  records = ["${aws_instance.hostname.private_ip}"]
}

output "hostname" {
  value = "${aws_route53_record.jumphost-01.name} (${aws_instance.jumphost-01.private_ip})\t[${aws_eip.jumphost-01.public_ip}]"
}

# External DNS
resource "aws_eip" "hostname" {
    instance = "${aws_instance.hostname.id}"
    vpc = true
}

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
