#######################
### Alert Condition ###
#######################

# Alert condition - STO
resource "newrelic_nrql_alert_condition" "kubernetes_deployment_sto_utilization" {
  count      = length(local.alerts_deployments)
  name       = "Namespace (${local.alerts_deployments[count.index].namespace_name}) | Deployment (${local.alerts_deployments[count.index].deployment_name})"
  account_id = var.NEW_RELIC_ACCOUNT_ID
  policy_id  = newrelic_alert_policy.kubernetes_deployment.id

  type        = "static"
  description = "Alert when STO utilization remains too high."

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
    query = "FROM K8sContainerSample SELECT max(fsUsedBytes)/max(fsCapacityBytes)*100 WHERE clusterName = '${var.cluster_name}' AND namespaceName = '${local.alerts_deployments[count.index].namespace_name}' AND deploymentName = '${local.alerts_deployments[count.index].deployment_name}' AND fsCapacityBytes IS NOT NULL FACET podName, containerName"
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
resource "newrelic_entity_tags" "kubernetes_deployment_sto_utilization" {
  count = length(local.alerts_deployments)
  guid  = newrelic_nrql_alert_condition.kubernetes_deployment_sto_utilization[count.index].entity_guid

  tag {
    key    = "k8sClusterName"
    values = ["${var.cluster_name}"]
  }

  tag {
    key    = "k8sObjectType"
    values = ["deployment"]
  }

  tag {
    key    = "namespaceName"
    values = ["${local.alerts_deployments[count.index].namespace_name}"]
  }

  tag {
    key    = "deploymentName"
    values = ["${local.alerts_deployments[count.index].deployment_name}"]
  }
}
