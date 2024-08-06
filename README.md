# ty-grafana-alloy-deployment-example
Grafana Alloy Deployment Example 

This repository is not exactly match what we use at Trendyol.

## Usage

```
module "elasticsearch-01" {
  source = "<redacted>/grafana-alloy.git//modules/openstack?ref=0.8.2"

  instance_tags = {
    environment = "prod"
    team        = "platform"
    cluster     = "elasticsearch-01"
  }

  node_flavor_name  = "ty.xlarge" # 8 cpu 32gb ram
  node_count        = 4

  grafana_alloy_config = <<EOT
  logging {
    level = "info"
    format = "json"
  }

  self_collect_v1 "default" {
    metrics_forward = prometheus_remote_write_v1.trendyol_observability.receiver
  }

  elasticsearch_exporter_v1 "venus" {
    consul_datacenter       = "venus"

    metrics_forward = prometheus_remote_write_v1.trendyol_observability.receiver
  }

  prometheus_remote_write_v1 "trendyol_observability" {
    url = "<redacted>"
  }
EOT
}
```
