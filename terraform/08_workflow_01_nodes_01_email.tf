################
### Workflow ###
################

resource "newrelic_workflow" "kubernetes_nodes" {
  name       = "k8s-${var.cluster_name}-workflow-nodes"
  account_id = var.NEW_RELIC_ACCOUNT_ID

  # enrichments_enabled   = true
  destinations_enabled  = true
  enabled               = true
  muting_rules_handling = "NOTIFY_ALL_ISSUES"

  # enrichments {
  #   nrql {
  #     name = "Metric"
  #     configuration {
  #       query = "SELECT count(*) FROM Metric WHERE metricName = 'myMetric'"
  #     }
  #   }
  # }

  issues_filter {
    name = "k8s-nodes-filter"
    type = "FILTER"

    predicate {
      attribute = "tag.k8sClusterName"
      operator  = "EXACTLY_MATCHES"
      values    = ["${var.cluster_name}"]
    }

    predicate {
      attribute = "tag.k8sObjectType"
      operator  = "EXACTLY_MATCHES"
      values    = ["node"]
    }
  }

  # Email
  dynamic "destination" {
    for_each = local.workflows.nodes.emails

    content {
      channel_id = newrelic_notification_channel.email[destination.value].id
    }
  }
}
