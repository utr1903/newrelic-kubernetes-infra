################
### Workflow ###
################

# Notification channel - Email
resource "newrelic_notification_channel" "kubernetes_nodes_sto_email" {
  for_each = local.emails

  name       = "k8s-${var.cluster_name}-workflow-nodes-sto-email-${each.key}"
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
resource "newrelic_workflow" "kubernetes_nodes_sto" {
  name       = "k8s-${var.cluster_name}-workflow-nodes-sto"
  account_id = var.NEW_RELIC_ACCOUNT_ID

  enrichments_enabled   = var.enable_enrichments
  enabled               = true
  muting_rules_handling = "NOTIFY_ALL_ISSUES"

  enrichments {
    nrql {
      name = "Top 10 STO using pods (bytes)"
      configuration {
        query = "FROM (FROM K8sContainerSample SELECT max(fsUsedBytes) AS `sto` WHERE clusterName = '${var.cluster_name}' AND nodeName IN {{entitiesData.names}} FACET namespace, podName, containerID TIMESERIES LIMIT MAX) SELECT sum(`sto`) TIMESERIES FACET namespace, podName LIMIT 10"
      }
    }
  }

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

    predicate {
      attribute = "tag.alertProperty"
      operator  = "EXACTLY_MATCHES"
      values    = ["stoUtilization"]
    }
  }

  dynamic "destination" {
    for_each = local.emails

    content {
      channel_id = newrelic_notification_channel.kubernetes_nodes_sto_email[destination.key].id
    }
  }
}
