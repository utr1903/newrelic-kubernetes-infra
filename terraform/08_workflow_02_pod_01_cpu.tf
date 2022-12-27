################
### Workflow ###
################

# Notification channel - Email
resource "newrelic_notification_channel" "kubernetes_pod_cpu_email" {
  for_each = local.emails

  name       = "k8s-${var.cluster_name}-workflow-pods-cpu-email-${each.key}"
  account_id = var.NEW_RELIC_ACCOUNT_ID
  type       = "EMAIL"

  destination_id = newrelic_notification_destination.email[each.key].id
  product        = "IINT"

  property {
    key   = "subject"
    value = "Alert - ${each.value}"
  }
}

# Workflow
resource "newrelic_workflow" "kubernetes_pod_cpu" {
  name       = "k8s-${var.cluster_name}-workflow-pods-cpu"
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
    name = "k8s-pods-filter"
    type = "FILTER"

    predicate {
      attribute = "tag.k8sClusterName"
      operator  = "EXACTLY_MATCHES"
      values    = ["${var.cluster_name}"]
    }

    predicate {
      attribute = "tag.k8sObjectType"
      operator  = "EXACTLY_MATCHES"
      values    = ["pod"]
    }

    predicate {
      attribute = "tag.alertProperty"
      operator  = "EXACTLY_MATCHES"
      values    = ["cpuUtilization"]
    }
  }

  dynamic "destination" {
    for_each = local.emails

    content {
      channel_id = newrelic_notification_channel.kubernetes_pod_cpu_email[destination.key].id
    }
  }
}
