################
### Workflow ###
################

# Notification channel - Email
resource "newrelic_notification_channel" "kubernetes_email_namespaces" {
  count = length(local.email_target_namespaces)

  name       = "k8s-${var.cluster_name}-workflow-email-${local.email_target_namespaces[count.index].target_name}-namespace-${local.email_target_namespaces[count.index].namespace_name}"
  account_id = var.NEW_RELIC_ACCOUNT_ID
  type       = "EMAIL"

  destination_id = newrelic_notification_destination.email[local.email_target_namespaces[count.index].target_name].id
  product        = "IINT"

  property {
    key   = "subject"
    value = "Alert - ${local.email_target_namespaces[count.index].target_name}"
  }
}

# Workflow
resource "newrelic_workflow" "kubernetes_email_namespaces" {
  count = length(local.email_target_namespaces)

  name       = newrelic_notification_channel.kubernetes_email_namespaces[count.index].name
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
      values    = ["deployment,daemonset,statefulset"]
    }

    predicate {
      attribute = "tag.namespaceName"
      operator  = "EXACTLY_MATCHES"
      values    = ["${local.email_target_namespaces[count.index].namespace_name}"]
    }
  }

  destination {
    channel_id = newrelic_notification_channel.kubernetes_email_namespaces[count.index].id
  }
}
