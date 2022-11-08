######################
### Alert Policies ###
######################

# Alert Policy - Node
resource "newrelic_alert_policy" "kubernetes_node" {
  name                = "K8s ${var.cluster_name} | Nodes"
  incident_preference = "PER_CONDITION_AND_TARGET"
}

# Alert Policy - Deployment
resource "newrelic_alert_policy" "kubernetes_deployment" {
  name                = "K8s ${var.cluster_name} | Deployments"
  incident_preference = "PER_CONDITION_AND_TARGET"
}
