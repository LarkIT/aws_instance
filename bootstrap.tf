data "template_file" "bootstrap" {
  template = "${file("${path.module}/templates/bootstrap.sh.tpl")}"
  vars {
    hostname      = "${var.host_prefix}-${var.hostname}.${var.internal_domain_name}"
    puppet_server = "${var.host_prefix}-foreman-01.${var.internal_domain_name}"
    gitlab_server = "${var.host_prefix}-gitlab-01.${var.internal_domain_name}"
    puppet_env    = "production"
    role          = "${var.role}"
  }
}

data "template_file" "foreman-install" {
  template = "${file("${path.module}/templates/foreman-install.sh.tpl")}"
  vars     = "${data.template_file.bootstrap-foreman-01.vars}"
}

data "template_cloudinit_config" "hostname" {
  part {
    filename     = "${var.bootscript_script}"
    content_type = "text/x-shellscript"
    content      = "${data.template_file.bootstrap.rendered}"
  }

#  part {
#    filename = "foreman-install.sh"
#    content_type = "text/x-shellscript"
#    content = "${data.template_file.foreman-install.rendered}"
#  }

  part {
    filename     = "${var.reboot_script}"
    content_type = "text/x-shellscript"
    content      = "${file("${path.module}/templates/reboot.sh")}"
  }
}
