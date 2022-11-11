##################
### Dashboards ###
##################

# Raw dashboard - Kubernetes Daemonset Overview
resource "newrelic_one_dashboard_raw" "kubernetes_daemonset_overview" {
  for_each = local.dashboards_daemonsets
  name     = "K8s Cluster ${var.cluster_name} | Namespace (${each.key}) | Daemonsets"

  ##########################
  ### DAEMONSET OVERVIEW ###
  ##########################
  dynamic "page" {
    for_each = each.value

    content {
      name = page.value

      # Page Description
      widget {
        title            = "Page Description"
        row              = 1
        column           = 1
        height           = 2
        width            = 4
        visualization_id = "viz.markdown"
        configuration = jsonencode({
          "text" : "## Daemonset Overview\nNamespace -> ${each.key}\nDaemonset -> ${page.value}."
        })
      }

      # Containers
      widget {
        title            = "Containers"
        row              = 1
        column           = 5
        height           = 4
        width            = 4
        visualization_id = "viz.table"
        configuration = jsonencode({
          "nrqlQueries" : [
            {
              "accountId" : var.NEW_RELIC_ACCOUNT_ID,
              "query" : "FROM K8sContainerSample SELECT uniques(containerName) WHERE podName IN (FROM K8sPodSample SELECT uniques(podName) WHERE clusterName = '${var.cluster_name}' AND namespaceName = '${each.key}' AND createdKind = 'DaemonSet' AND podName LIKE '${page.value}%' LIMIT MAX) LIMIT MAX"
            }
          ]
        })
      }

      # Container (Running)
      widget {
        title            = "Container (Running)"
        row              = 3
        column           = 1
        height           = 2
        width            = 2
        visualization_id = "viz.billboard"
        configuration = jsonencode({
          "nrqlQueries" : [
            {
              "accountId" : var.NEW_RELIC_ACCOUNT_ID,
              "query" : "FROM K8sContainerSample SELECT uniqueCount(containerName) AS `Running` WHERE clusterName = '${var.cluster_name}' AND namespaceName = '${each.key}' AND createdKind = 'DaemonSet' AND podName LIKE '${page.value}%' AND status = 'Running' LIMIT MAX"
            }
          ]
        })
      }

      # Container (Terminated/Unknown)
      widget {
        title            = "Container (Terminated/Unknown)"
        row              = 3
        column           = 3
        height           = 2
        width            = 2
        visualization_id = "viz.billboard"
        configuration = jsonencode({
          "nrqlQueries" : [
            {
              "accountId" : var.NEW_RELIC_ACCOUNT_ID,
              "query" : "FROM K8sContainerSample SELECT uniqueCount(containerName) AS `Not Running` WHERE clusterName = '${var.cluster_name}' AND namespaceName = '${each.key}' AND createdKind = 'DaemonSet' AND podName LIKE '${page.value}%' AND status != 'Running' LIMIT MAX"
            }
          ]
        })
      }

      # Pod (Running)
      widget {
        title            = "Pod (Running)"
        row              = 1
        column           = 9
        height           = 2
        width            = 2
        visualization_id = "viz.billboard"
        configuration = jsonencode({
          "nrqlQueries" : [
            {
              "accountId" : var.NEW_RELIC_ACCOUNT_ID,
              "query" : "FROM K8sPodSample SELECT uniqueCount(podName) OR 0 AS `Running` WHERE clusterName = '${var.cluster_name}' AND namespaceName = '${each.key}' AND createdKind = 'DaemonSet' AND podName LIKE '${page.value}%' AND status = 'Running' LIMIT MAX"
            }
          ]
        })
      }

      # Pod (Pending)
      widget {
        title            = "Pod (Pending)"
        row              = 1
        column           = 11
        height           = 2
        width            = 2
        visualization_id = "viz.billboard"
        configuration = jsonencode({
          "nrqlQueries" : [
            {
              "accountId" : var.NEW_RELIC_ACCOUNT_ID,
              "query" : "FROM K8sPodSample SELECT uniqueCount(podName) OR 0 AS `Pending` WHERE clusterName = '${var.cluster_name}' AND namespaceName = '${each.key}' AND createdKind = 'DaemonSet' AND podName LIKE '${page.value}%' AND status = 'Pending' LIMIT MAX"
            }
          ]
        })
      }

      # Pod (Failed)
      widget {
        title            = "Pod (Failed)"
        row              = 3
        column           = 9
        height           = 2
        width            = 2
        visualization_id = "viz.billboard"
        configuration = jsonencode({
          "nrqlQueries" : [
            {
              "accountId" : var.NEW_RELIC_ACCOUNT_ID,
              "query" : "FROM K8sPodSample SELECT uniqueCount(podName) OR 0 AS `Failed` WHERE clusterName = '${var.cluster_name}' AND namespaceName = '${each.key}' AND createdKind = 'DaemonSet' AND podName LIKE '${page.value}%' AND status = 'Failed' LIMIT MAX"
            }
          ]
        })
      }

      # Pod (Unknown)
      widget {
        title            = "Pod (Unknown)"
        row              = 3
        column           = 11
        height           = 2
        width            = 2
        visualization_id = "viz.billboard"
        configuration = jsonencode({
          "nrqlQueries" : [
            {
              "accountId" : var.NEW_RELIC_ACCOUNT_ID,
              "query" : "FROM K8sPodSample SELECT uniqueCount(podName) OR 0 AS `Unknown` WHERE clusterName = '${var.cluster_name}' AND namespaceName = '${each.key}' AND createdKind = 'DaemonSet' AND podName LIKE '${page.value}%' AND status = 'Unknown' LIMIT MAX"
            }
          ]
        })
      }

      # Top 10 CPU using pods (mcores)
      widget {
        title            = "Top 10 CPU using pods (mcores)"
        row              = 5
        column           = 1
        width            = 6
        height           = 3
        visualization_id = "viz.area"
        configuration = jsonencode({
          "nrqlQueries" : [
            {
              "accountId" : var.NEW_RELIC_ACCOUNT_ID,
              "query" : "FROM (FROM K8sContainerSample SELECT max(cpuUsedCores)*1000 AS `cpu` WHERE clusterName = '${var.cluster_name}' AND namespaceName = '${each.key}' AND podName IN (FROM K8sPodSample SELECT uniques(podName) WHERE createdKind = 'DaemonSet' AND podName LIKE '${page.value}%') FACET podName, containerID TIMESERIES LIMIT MAX) SELECT sum(`cpu`) FACET podName TIMESERIES LIMIT 10"
            }
          ]
        })
      }

      # Top 10 CPU utilizing pods (%)
      widget {
        title            = "Top 10 CPU utilizing pods (%)"
        row              = 5
        column           = 7
        width            = 6
        height           = 3
        visualization_id = "viz.line"
        configuration = jsonencode({
          "nrqlQueries" : [
            {
              "accountId" : var.NEW_RELIC_ACCOUNT_ID,
              "query" : "FROM (FROM K8sContainerSample SELECT max(cpuUsedCores) AS `usage`, max(cpuLimitCores) AS `limit` WHERE clusterName = '${var.cluster_name}' AND namespaceName = '${each.key}' AND podName IN (FROM K8sPodSample SELECT uniques(podName) WHERE createdKind = 'DaemonSet' AND podName LIKE '${page.value}%') AND cpuLimitCores IS NOT NULL FACET podName, containerID TIMESERIES LIMIT MAX) SELECT sum(`usage`)/sum(`limit`)*100 FACET podName TIMESERIES LIMIT 10"
            }
          ]
        })
      }

      # Top 10 MEM using pods (bytes)
      widget {
        title            = "Top 10 MEM using pods (bytes)"
        row              = 8
        column           = 1
        width            = 6
        height           = 3
        visualization_id = "viz.area"
        configuration = jsonencode({
          "nrqlQueries" : [
            {
              "accountId" : var.NEW_RELIC_ACCOUNT_ID,
              "query" : "FROM (FROM K8sContainerSample SELECT max(memoryUsedBytes) AS `mem` WHERE clusterName = '${var.cluster_name}' AND namespaceName = '${each.key}' AND podName IN (FROM K8sPodSample SELECT uniques(podName) WHERE createdKind = 'DaemonSet' AND podName LIKE '${page.value}%') FACET podName, containerID TIMESERIES LIMIT MAX) SELECT sum(`mem`) FACET podName TIMESERIES LIMIT 10"
            }
          ]
        })
      }

      # Top 10 MEM utilizing pods (%)
      widget {
        title            = "Top 10 MEM utilizing pods (%)"
        row              = 8
        column           = 7
        width            = 6
        height           = 3
        visualization_id = "viz.line"
        configuration = jsonencode({
          "nrqlQueries" : [
            {
              "accountId" : var.NEW_RELIC_ACCOUNT_ID,
              "query" : "FROM (FROM K8sContainerSample SELECT max(memoryUsedBytes) AS `usage`, max(memoryLimitBytes) AS `limit` WHERE clusterName = '${var.cluster_name}' AND namespaceName = '${each.key}' AND podName IN (FROM K8sPodSample SELECT uniques(podName) WHERE createdKind = 'DaemonSet' AND podName LIKE '${page.value}%') AND memoryLimitBytes IS NOT NULL FACET podName, containerID TIMESERIES LIMIT MAX) SELECT sum(`usage`)/sum(`limit`)*100 FACET podName TIMESERIES LIMIT 10"
            }
          ]
        })
      }

      # Container STO Usage per Pod (bytes)
      widget {
        title            = "Container STO Usage per Pod (bytes)"
        row              = 11
        column           = 1
        width            = 6
        height           = 3
        visualization_id = "viz.area"
        configuration = jsonencode({
          "nrqlQueries" : [
            {
              "accountId" : var.NEW_RELIC_ACCOUNT_ID,
              "query" : "FROM (FROM K8sContainerSample SELECT max(fsUsedBytes) AS `sto` WHERE clusterName = '${var.cluster_name}' AND namespaceName = '${each.key}' AND podName IN (FROM K8sPodSample SELECT uniques(podName) WHERE createdKind = 'DaemonSet' AND podName LIKE '${page.value}%') FACET podName, containerID TIMESERIES LIMIT MAX) SELECT sum(`sto`) FACET podName TIMESERIES LIMIT 10"
            }
          ]
        })
      }

      # Container STO Utilization per Pod (%)
      widget {
        title            = "Container STO Utilization per Pod (%)"
        row              = 11
        column           = 7
        width            = 6
        height           = 3
        visualization_id = "viz.line"
        configuration = jsonencode({
          "nrqlQueries" : [
            {
              "accountId" : var.NEW_RELIC_ACCOUNT_ID,
              "query" : "FROM (FROM K8sContainerSample SELECT max(fsUsedBytes) AS `usage`, max(fsCapacityBytes) AS `limit` WHERE clusterName = '${var.cluster_name}' AND namespaceName = '${each.key}' AND podName IN (FROM K8sPodSample SELECT uniques(podName) WHERE createdKind = 'DaemonSet' AND podName LIKE '${page.value}%') AND fsCapacityBytes IS NOT NULL FACET podName, containerID TIMESERIES LIMIT MAX) SELECT sum(`usage`)/sum(`limit`)*100 FACET podName TIMESERIES LIMIT 10"
            }
          ]
        })
      }
    }
  }
}
