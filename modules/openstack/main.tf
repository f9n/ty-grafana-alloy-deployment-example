resource "openstack_compute_instance_v2" "nodes" {
  count            = var.node_count

  name             = "grafana-alloy-${count.index}"
  flavor_name      = var.node_flavor_name
  image_name       = var.image
  key_pair         = var.key_pair_name
  security_groups  = var.security_groups
  availability_zone = var.availability_zone
  network {
    name = var.network_name
  }

  tags = local.node_instance_tags

  metadata = {
    "grafana_alloy_version" = var.grafana_alloy_version
  }
}

resource "null_resource" "run_ansible_playbook_configure" {
  triggers = {
    inventory                  = local.inventory_hosts
    tf_reapply_config_revision = var.tf_reapply_config_revision
    _config                    = var.grafana_alloy_config
    grafana_alloy_version      = var.grafana_alloy_version
  }

  provisioner "local-exec" {
    command     = file(format("%s/../../files/scripts/cluster_formation.sh", path.module))
    interpreter = ["bash", "-c"]
    environment = {
      MODULE_PATH                  = path.module
      INVENTORY_HOSTS              = local.inventory_hosts
      GRAFANA_ALLOY_VERSION        = var.grafana_alloy_version
      GRAFANA_ALLOY_RETRY_COUNT    = var.grafana_alloy_retry_count
      GRAFANA_ALLOY_DELAY_DURATION = var.grafana_alloy_delay_duration
      GRAFANA_ALLOY_CONFIG         = var.grafana_alloy_config
    }
  }

  depends_on = [ openstack_compute_instance_v2.nodes ]
}
