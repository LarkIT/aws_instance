data "template_file" "bootstrap" {
  template = "${file("${path.module}/templates/bootstrap.sh.tpl")}"
  vars {
    hostname      = "${var.host_prefix}-${var.hostname}.${var.internal_domain_name}"
    puppet_server = "${var.host_prefix}-foreman-01.${var.internal_domain_name}"
    puppet_env    = "production"
    role          = "jumphost"
  }
}

data "template_cloudinit_config" "hostname" {
  part {
    filename     = "${var.bootscript_script}"
    content_type = "text/x-shellscript"
    content      = "${data.template_file.bootstrap.rendered}"
  }
  part {
    filename     = "${var.reboot_script}"
    content_type = "text/x-shellscript"
    content      = "${file("${path.module}/templates/reboot.sh")}"
  }
}
