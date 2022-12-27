################
### Workflow ###
################

# Notification channel - Email
resource "newrelic_notification_channel" "kubernetes_email_nodes" {
  count = length(local.email_targets.nodes)

  name       = "k8s-${var.cluster_name}-workflow-email-${local.email_targets.nodes[count.index]}-nodes"
  account_id = var.NEW_RELIC_ACCOUNT_ID
  type       = "EMAIL"

  destination_id = newrelic_notification_destination.email[local.email_targets.nodes[count.index]].id
  product        = "IINT"

  property {
    key   = "subject"
    value = "Alert - ${local.email_targets.nodes[count.index]}"
  }
}

# Workflow
resource "newrelic_workflow" "kubernetes_email_nodes" {
  count = length(local.email_targets.nodes)

  name       = newrelic_notification_channel.kubernetes_email_nodes[count.index].name
  account_id = var.NEW_RELIC_ACCOUNT_ID

  enrichments_enabled   = var.enable_enrichments
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

  destination {
    channel_id = newrelic_notification_channel.kubernetes_email_nodes[count.index].id
  }
}
