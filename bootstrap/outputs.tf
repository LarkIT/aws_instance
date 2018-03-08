# output "foreman_cloutinit" {
#   value = "${data.template_cloudinit_config.foreman.rendered}"
# }

# output "gitlab_cloutinit" {
#   value = "${data.template_cloudinit_config.gitlab.rendered}"
# }

# output "pulp_cloutinit" {
#   value = "${data.template_cloudinit_config.pulp.rendered}"
# }

output "base_cloudinit" {
  value = "${data.template_cloudinit_config.base.rendered}"
}
