variable "availability_zone" {
  type        = string
  description = "Availability Zone"
}

variable "server_groups_policies" {
  type        = list(any)
  description = "Server Groups Policies"
  default = [
    "anti-affinity"
  ]
}

variable "key_pair_name" {
  type        = string
  default     = "platform"
  description = "The key pair name of vm instance"
}

variable "network_name" {
  type        = string
  description = "Network Name"
}

variable "security_groups" {
  type        = list(any)
  description = "Security Groups"
  default = [
    "default"
  ]
}

variable "instance_tags" {
  type        = map(any)
  description = <<EOF
Instance tags like these:
  {
    environment = "prod"
    team        = "platform"
    cluster     = "ofli-test-2"
  }
EOF
  validation {
    condition = length(
      regexall(
        format(".*%s.*", var.instance_tags["team"]),
        var.instance_tags["cluster"]
      )
    ) <= 0
    error_message = "The 'cluster' tag cannot contain 'team' tag."
  }
}

variable "image" {
  type        = string
  description = "Instance Image"
  default     = "ubuntu-22.04"
}

variable "node_count" {
  type        = number
  default     = 1
  description = "Nodes Count"
}

variable "node_flavor_name" {
  type        = string
  description = "The type of vm instance"
  default     = "ty.micro"
}

variable "tf_reapply_config_revision" {
  type        = number
  description = "This variable used in applying configurations for provisioning. Increase/decrease this to re-apply whole configuration set"
  default     = 1
  validation {
    condition = (
      var.tf_reapply_config_revision >= 1
    )
    error_message = "The tf_reapply_config_revision can't be less than 1."
  }
}

variable "grafana_alloy_version" {
  type        = string
  description = "Grafana Alloy Version"
  default     = "1.2.0"
}

variable "grafana_alloy_retry_count" {
  type        = number
  description = "Grafana Alloy Retry Count"
  default     = 10
}

variable "grafana_alloy_delay_duration" {
  type        = number
  description = "Grafana Alloy Delay Duration"
  default     = 30
}

variable "grafana_alloy_config" {
  type        = string
  description = "Config for grafana alloy"
  default     = <<EOT
prometheus.scrape "default" {
  targets = [{"__address__" = "localhost:12345"}]
  forward_to = [
    //prometheus.remote_write.prom.receiver,
  ]
}

/*
prometheus.remote_write "prom" {
  endpoint {
      url = "https://prometheus-prod-13-prod-us-east-0.grafana.net/api/prom/push"

      basic_auth {
      username = "149xxx"
      password = "glc_xxx"
    }
  }
}
*/
EOT

}
