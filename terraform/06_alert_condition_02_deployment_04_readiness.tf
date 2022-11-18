#######################
### Alert Condition ###
#######################

# Alert condition - Readiness
resource "newrelic_nrql_alert_condition" "kubernetes_deployment_readiness" {
  count      = length(local.alerts_deployments)
  name       = "Namespace (${local.alerts_deployments[count.index][0]}) | Deployment (${local.alerts_deployments[count.index][1]}) | MEM"
  account_id = var.NEW_RELIC_ACCOUNT_ID
  policy_id  = newrelic_alert_policy.kubernetes_deployment.id

  type        = "static"
  description = "Alert when a pod in a deployment is not ready."

  enabled                        = true
  violation_time_limit_seconds   = 3 * 24 * 60 * 60 // days calculated into seconds
  fill_option                    = "none"
  aggregation_window             = 1 * 60 // minutes calculated into seconds
  aggregation_method             = "event_flow"
  aggregation_delay              = 2 * 60  // minutes calculated into seconds
  expiration_duration            = 20 * 60 // minutes calculated into seconds
  open_violation_on_expiration   = true
  close_violations_on_expiration = true
  slide_by                       = 30 // seconds

  nrql {
    query = "FROM K8sPodSample SELECT uniqueCount(podName) WHERE clusterName = '${var.cluster_name}' AND namespaceName = '${local.alerts_deployments[count.index][0]}' AND deploymentName = '${local.alerts_deployments[count.index][1]}' AND isReady = 0"
  }

  warning {
    operator              = "above"
    threshold             = 0
    threshold_duration    = 5 * 60 // minutes calculated into seconds
    threshold_occurrences = "all"
  }

  critical {
    operator              = "above"
    threshold             = 1
    threshold_duration    = 5 * 60 // minutes calculated into seconds
    threshold_occurrences = "all"
  }
}

# Alert condition tag - Readiness
resource "newrelic_entity_tags" "kubernetes_deployment_readiness" {
  count = length(local.alerts_deployments)
  guid  = newrelic_nrql_alert_condition.kubernetes_deployment_readiness[count.index].entity_guid

  tag {
    key    = "k8sClusterName"
    values = ["${var.cluster_name}"]
  }

  tag {
    key    = "k8sObjectType"
    values = ["deployment"]
  }

  tag {
    key    = "alertProperty"
    values = ["readiness"]
  }

  tag {
    key    = "namespaceName"
    values = ["${local.alerts_deployments[count.index][0]}"]
  }

  tag {
    key    = "deploymentName"
    values = ["${local.alerts_deployments[count.index][1]}"]
  }
}
