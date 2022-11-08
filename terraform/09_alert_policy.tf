######################
### Alert Policies ###
######################

# Alert Policies
resource "newrelic_alert_policy" "kubernetes_node" {
  name                = "K8s ${var.cluster_name} | Nodes"
  incident_preference = "PER_CONDITION_AND_TARGET"
}
#########
