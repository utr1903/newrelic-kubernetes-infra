#######################
### Alert Condition ###
#######################

# Alert condition - MEM
resource "newrelic_nrql_alert_condition" "kubernetes_node_mem_utilization" {
  name       = "K8s Cluster ${var.cluster_name} | Nodes | MEM"
  account_id = var.NEW_RELIC_ACCOUNT_ID
  policy_id  = newrelic_alert_policy.kubernetes_node.id

  type        = "static"
  description = "Alert when MEM utilization remains too high."

  enabled                        = true
  violation_time_limit_seconds   = 3 * 24 * 60 * 60 // days calculated into seconds
  fill_option                    = "none"
  aggregation_window             = 60
  aggregation_method             = "event_flow"
  aggregation_delay              = 120
  expiration_duration            = 120
  open_violation_on_expiration   = true
  close_violations_on_expiration = true
  slide_by                       = 30

  nrql {
    query = "FROM Metric SELECT average(k8s.node.memoryUsedBytes)/max(k8s.node.capacityMemoryBytes)*100 WHERE clusterName = '${var.cluster_name}' FACET k8s.nodeName"
  }

  warning {
    operator              = "above"
    threshold             = 50
    threshold_duration    = 60 * 5 // minutes calculated into seconds
    threshold_occurrences = "all"
  }

  critical {
    operator              = "above"
    threshold             = 75
    threshold_duration    = 60 * 5 // minutes calculated into seconds
    threshold_occurrences = "all"
  }
}

# Alert condition tag - MEM
resource "newrelic_entity_tags" "kubernetes_node_mem_utilization" {
  guid = newrelic_nrql_alert_condition.kubernetes_node_mem_utilization.entity_guid

  tag {
    key    = "k8sClusterName"
    values = ["${var.cluster_name}"]
  }

  tag {
    key    = "alertProperty"
    values = ["memUtilization"]
  }
}
