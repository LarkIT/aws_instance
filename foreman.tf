data "template_file" "foreman" {
  template = "${file("${path.module}/templates/foreman-install.sh.tpl")}"
  vars {
    hostname      = "${var.host_prefix}-foreman-01.${var.internal_domain_name}"
    puppet_server = "${var.host_prefix}-foreman-01.${var.internal_domain_name}"
    gitlab_server = "${var.host_prefix}-gitlab-01.${var.internal_domain_name}"
    puppet_env    = "production"
    role          = "${var.role}"
  }
}

#provisioner "file" {
#  content = "${data.template_file.foreman.rendered}"
#  destination = "/tmp/foreman.sh"
#}


data "template_cloudinit_config" "foreman" {
  part {
    filename = "foreman-install.sh"
    content_type = "text/x-shellscript"
    content = "${data.template_file.foreman.rendered}"
  }
}
