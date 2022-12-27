######################
### Alert Policies ###
######################

# Alert Policy - Node
resource "newrelic_alert_policy" "kubernetes_node" {
  name                = "K8s ${var.cluster_name} | Nodes"
  incident_preference = "PER_CONDITION_AND_TARGET"
}

# Alert Policy - Pod
resource "newrelic_alert_policy" "kubernetes_pod" {
  name                = "K8s ${var.cluster_name} | Pods"
  incident_preference = "PER_CONDITION_AND_TARGET"
}
