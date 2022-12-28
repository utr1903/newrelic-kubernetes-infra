################
### Workflow ###
################

# Notification channel - Email
resource "newrelic_notification_channel" "kubernetes_pod_mem_email" {
  for_each = local.emails

  name       = "k8s-${var.cluster_name}-workflow-pods-mem-email-${each.key}"
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
resource "newrelic_workflow" "kubernetes_pod_mem" {
  name       = "k8s-${var.cluster_name}-workflow-pods-mem"
  account_id = var.NEW_RELIC_ACCOUNT_ID

  enrichments_enabled   = var.enable_enrichments
  enabled               = true
  muting_rules_handling = "NOTIFY_ALL_ISSUES"

  enrichments {
    nrql {
      name = "Node, namespace & pod of the problematic container"
      configuration {
        query = "FROM K8sContainerSample SELECT latest(nodeName), latest(namespaceName), latest(podName) WHERE entityId IN {{entitiesData.ids}} FACET containerName LIMIT MAX"
      }
    }
  }

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
      values    = ["memUtilization"]
    }
  }

  dynamic "destination" {
    for_each = local.emails

    content {
      channel_id = newrelic_notification_channel.kubernetes_pod_mem_email[destination.key].id
    }
  }
}
