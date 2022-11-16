#######################
### Alert Condition ###
#######################

# Alert condition - STO
resource "newrelic_nrql_alert_condition" "kubernetes_node_sto_utilization" {
  name       = "K8s Cluster ${var.cluster_name} | Nodes | STO"
  account_id = var.NEW_RELIC_ACCOUNT_ID
  policy_id  = newrelic_alert_policy.kubernetes_node.id

  type        = "static"
  description = "Alert when STO utilization remains too high."

  enabled                        = true
  violation_time_limit_seconds   = 3 * 24 * 60 * 60 // days calculated into seconds
  fill_option                    = "none"
  aggregation_window             = 1 *  60 // minutes calculated into seconds
  aggregation_method             = "event_flow"
  aggregation_delay              = 2 * 60 // minutes calculated into seconds
  expiration_duration            = 20 * 60 // minutes calculated into seconds
  open_violation_on_expiration   = true
  close_violations_on_expiration = true
  slide_by                       = 30 // seconds

  nrql {
    query = "FROM K8sNodeSample SELECT max(fsUsedBytes)/max(fsCapacityBytes)*100 WHERE clusterName = '${var.cluster_name}' FACET nodeName"
  }

  warning {
    operator              = "above"
    threshold             = 50
    threshold_duration    = 5 * 60 // minutes calculated into seconds
    threshold_occurrences = "all"
  }

  critical {
    operator              = "above"
    threshold             = 75
    threshold_duration    = 5 * 60 // minutes calculated into seconds
    threshold_occurrences = "all"
  }
}

# Alert condition tag - STO
resource "newrelic_entity_tags" "kubernetes_node_sto_utilization" {
  guid = newrelic_nrql_alert_condition.kubernetes_node_sto_utilization.entity_guid

  tag {
    key    = "k8sClusterName"
    values = ["${var.cluster_name}"]
  }
  tag {
    key    = "k8sObjectType"
    values = ["node"]
  }

  tag {
    key    = "k8sObjectType"
    values = ["node"]
  }

  tag {
    key    = "alertProperty"
    values = ["stoUtilization"]
  }
}
