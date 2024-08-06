locals {
  module_tags = {
    service           = "grafana-alloy"
    app               = "grafana-alloy"
    tf_module_version = "0.8.2"
    image             = var.image
  }

  cluster_provider_identifier = format(
    "%s-%s-%s",
    var.instance_tags["team"],
    var.instance_tags["environment"],
    var.instance_tags["cluster"]
  )

  node_instance_tags = merge(local.module_tags, var.instance_tags, {
    alloy_cluster = local.cluster_provider_identifier
  })

  all_nodes       = concat(module.node.servers)
  inventory_hosts = join(",", [for v in local.all_nodes : v.ip])
}
