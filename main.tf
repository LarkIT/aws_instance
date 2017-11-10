module "bootstrap" {
  source               = "git::https://nfosdick@bitbucket.org/larkit/bootstrap.git"
  internal_domain_name = "${var.internal_domain_name}"
  host_prefix          = "${var.host_prefix}"
  role                 = "${var.role}"
#  pp_env               = "${var.pp_env}"
  hostname             = "${var.hostname}"
  region               = "${var.region}" 
}

resource "aws_instance" "hostname" {
    ami                    = "${lookup(var.centos7-ami, var.region)}"
    availability_zone      = "${var.region}${var.availability_zone}"
    instance_type          = "${var.instance_type}"
    key_name               = "${var.aws_key_name}"
    vpc_security_group_ids = [ "${var.security_groups}" ]
    subnet_id              = "${var.subnet_id}"
#    user_data              = "${var.bootstrap}"
    user_data              = "${module.bootstrap.base_cloutinit}"
    iam_instance_profile   = "${var.iam_instance_profile}"

    lifecycle {
      ignore_changes = ["user_data"]
    }

    tags {
        Name = "${var.host_prefix}-${var.hostname}"
    }
}

resource "aws_route53_record" "hostname" {
  zone_id = "${var.route53_internal_id}"
  name    = "${aws_instance.hostname.tags.Name}"
  type    = "A"
  ttl     = "300"
  records = ["${aws_instance.hostname.private_ip}"]
}

#output "hostname" {
#  value = "${aws_route53_record.hostname.name} (${aws_instance.hostname.private_ip})\t[${aws_eip.hostname.public_ip}]"
#}

resource "aws_eip" "hostname" {
    count    = "${var.enable_aws_eip}"
    instance = "${aws_instance.hostname.id}"
    vpc      = true
}

resource "aws_route53_record" "hostname-ext" {
  count   = "${var.external_dns_enable}"
  zone_id = "${var.route53_external_id}"
  #name    = "${aws_instance.hostname.tags.Name}"
  name    = "${var.external_hostname}"
  type    = "A"
  ttl     = "300"
  records = ["${aws_eip.hostname.public_ip}"]
}

resource "aws_ebs_volume" "volume" {
  count             = "${var.enable_ebs_volume}"
  availability_zone = "${var.region}${var.availability_zone}"
  size              = "${var.ebs_volume_size}"
  tags {
    Name = "${var.role} Volume for ${var.host_prefix}-${var.hostname}"
  }
}

resource "aws_volume_attachment" "ebs_att" {
  count       = "${var.enable_ebs_volume}"
  device_name = "${var.device_name}"
  volume_id   = "${aws_ebs_volume.volume.id}"
  instance_id = "${aws_instance.hostname.id}"
}

output "hostname-ext" {
  value = "${aws_route53_record.hostname-ext.fqdn} (${aws_eip.hostname.public_ip})"
}

# Special SSH Command for JumpHost
#output "hostname-ssh-command" {
#  value = "ssh -A centos@${aws_eip.hostname.public_ip} -L 9443:${aws_instance.gitlab-01.tags.Name}:443 -L 2222:${aws_instance.gitlab-01.tags.Name}:22 -L 8443:${aws_instance.foreman-01.tags.Name}:443 "
#}
