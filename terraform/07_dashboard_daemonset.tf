##################
### Dashboards ###
##################

# Raw dashboard - Kubernetes Daemonset Overview
resource "newrelic_one_dashboard_raw" "kubernetes_daemonset_overview" {
  count = length(var.namespace_names)
  name = "K8s Cluster ${var.cluster_name} | Namespace (${var.namespace_names[count.index]}) | Daemonsets"

  ##########################
  ### DAEMONSET OVERVIEW ###
  ##########################
  dynamic "page" {
    for_each = var.daemonsets[index(var.daemonsets.*.namespaceName, var.namespace_names[count.index])].daemonsetNames

    content {
      name = "${page.value}"

      # Page Description
      widget {
        title  = "Page Description"
        row    = 1
        column = 1
        height = 2
        width  = 4
        visualization_id = "viz.markdown"
        configuration = jsonencode(
        {
          "text": "## Daemonset Overview\nNamespace -> ${var.namespace_names[count.index]}\nDaemonset -> ${page.value}."
        })
      }

      # Containers
      widget {
        title  = "Containers"
        row    = 1
        column = 5
        height = 4
        width  = 4
        visualization_id = "viz.table"
        configuration = jsonencode(
        {
          "nrqlQueries": [
            {
              "accountId": var.NEW_RELIC_ACCOUNT_ID,
              "query": "FROM K8sContainerSample SELECT uniques(containerName) WHERE podName IN (FROM K8sPodSample SELECT uniques(podName) WHERE clusterName = '${var.cluster_name}' AND createdKind = 'DaemonSet' AND podName LIKE '${page.value}%' LIMIT MAX) LIMIT MAX"
            }
          ]
        })
      }

      # Container (Running)
      widget {
        title  = "Container (Running)"
        row    = 3
        column = 1
        height = 2
        width  = 2
        visualization_id = "viz.billboard"
        configuration = jsonencode(
        {
          "nrqlQueries": [
            {
              "accountId": var.NEW_RELIC_ACCOUNT_ID,
              "query": "FROM K8sContainerSample SELECT uniqueCount(containerName) AS `Running` WHERE clusterName = '${var.cluster_name}' AND createdKind = 'DaemonSet' AND podName LIKE '${page.value}%' AND status = 'Running' LIMIT MAX"
            }
          ]
        })
      }

      # Container (Terminated/Unknown)
      widget {
        title  = "Container (Terminated/Unknown)"
        row    = 3
        column = 3
        height = 2
        width  = 2
        visualization_id = "viz.billboard"
        configuration = jsonencode(
        {
          "nrqlQueries": [
            {
              "accountId": var.NEW_RELIC_ACCOUNT_ID,
              "query": "FROM K8sContainerSample SELECT uniqueCount(containerName) AS `Not Running` WHERE clusterName = '${var.cluster_name}' AND createdKind = 'DaemonSet' AND podName LIKE '${page.value}%' AND status != 'Running' LIMIT MAX"
            }
          ]
        })
      }

      # Pod (Running)
      widget {
        title  = "Pod (Running)"
        row    = 1
        column = 9
        height = 2
        width  = 2
        visualization_id = "viz.billboard"
        configuration = jsonencode(
        {
          "nrqlQueries": [
            {
              "accountId": var.NEW_RELIC_ACCOUNT_ID,
              "query": "FROM K8sPodSample SELECT uniqueCount(podName) OR 0 AS `Running` WHERE clusterName = '${var.cluster_name}' AND createdKind = 'DaemonSet' AND podName LIKE '${page.value}%' AND status = 'Running' LIMIT MAX"
            }
          ]
        })
      }

      # Pod (Pending)
      widget {
        title  = "Pod (Pending)"
        row    = 1
        column = 11
        height = 2
        width  = 2
        visualization_id = "viz.billboard"
        configuration = jsonencode(
        {
          "nrqlQueries": [
            {
              "accountId": var.NEW_RELIC_ACCOUNT_ID,
              "query": "FROM K8sPodSample SELECT uniqueCount(podName) OR 0 AS `Pending` WHERE clusterName = '${var.cluster_name}' AND createdKind = 'DaemonSet' AND podName LIKE '${page.value}%' AND status = 'Pending' LIMIT MAX"
            }
          ]
        })
      }

      # Pod (Failed)
      widget {
        title  = "Pod (Failed)"
        row    = 3
        column = 9
        height = 2
        width  = 2
        visualization_id = "viz.billboard"
        configuration = jsonencode(
        {
          "nrqlQueries": [
            {
              "accountId": var.NEW_RELIC_ACCOUNT_ID,
              "query": "FROM K8sPodSample SELECT uniqueCount(podName) OR 0 AS `Failed` WHERE clusterName = '${var.cluster_name}' AND createdKind = 'DaemonSet' AND podName LIKE '${page.value}%' AND status = 'Failed' LIMIT MAX"
            }
          ]
        })
      }

      # Pod (Unknown)
      widget {
        title  = "Pod (Unknown)"
        row    = 3
        column = 11
        height = 2
        width  = 2
        visualization_id = "viz.billboard"
        configuration = jsonencode(
        {
          "nrqlQueries": [
            {
              "accountId": var.NEW_RELIC_ACCOUNT_ID,
              "query": "FROM K8sPodSample SELECT uniqueCount(podName) OR 0 AS `Unknown` WHERE clusterName = '${var.cluster_name}' AND createdKind = 'DaemonSet' AND podName LIKE '${page.value}%' AND status = 'Unknown' LIMIT MAX"
            }
          ]
        })
      }

      # Container CPU Usage per Pod (mcores)
      widget {
        title  = "Container CPU Usage per Pod (mcores)"
        row    = 5
        column = 1
        width  = 6
        visualization_id = "viz.area"
        configuration = jsonencode(
        {
          "nrqlQueries": [
            {
              "accountId": var.NEW_RELIC_ACCOUNT_ID,
              "query": "FROM Metric SELECT average(k8s.container.cpuUsedCores)*1000 AS `cpu` WHERE k8s.clusterName = '${var.cluster_name}' AND k8s.podName IN (FROM K8sPodSample SELECT uniques(podName) WHERE createdKind = 'DaemonSet' AND podName LIKE '${page.value}%') FACET k8s.podName TIMESERIES LIMIT MAX"
            }
          ]
        })
      }

      # Container CPU Utilization per Pod (%)
      widget {
        title  = "Container CPU Utilization per Pod (%)"
        row    = 5
        column = 7
        width  = 6
        height = 3
        visualization_id = "viz.line"
        configuration = jsonencode(
        {
          "nrqlQueries": [
            {
              "accountId": var.NEW_RELIC_ACCOUNT_ID,
              "query": "FROM Metric SELECT average(k8s.container.cpuUsedCores)/average(k8s.container.cpuLimitCores)*100 WHERE k8s.podName IN (FROM K8sPodSample SELECT uniques(podName) WHERE createdKind = 'DaemonSet' AND podName LIKE '${page.value}%') AND k8s.containerName IN (FROM Metric SELECT uniques(k8s.containerName) WHERE k8s.clusterName = '${var.cluster_name}' AND k8s.container.cpuLimitCores IS NOT NULL LIMIT MAX) FACET k8s.podName TIMESERIES LIMIT MAX"
            }
          ]
        })
      }

      # Container MEM Usage per Pod (bytes)
      widget {
        title  = "Container MEM Usage per Pod (bytes)"
        row    = 8
        column = 1
        width  = 6
        height = 3
        visualization_id = "viz.area"
        configuration = jsonencode(
        {
          "nrqlQueries": [
            {
              "accountId": var.NEW_RELIC_ACCOUNT_ID,
              "query": "FROM Metric SELECT average(k8s.container.memoryUsedBytes) AS `mem` WHERE k8s.clusterName = '${var.cluster_name}' AND k8s.podName IN (FROM K8sPodSample SELECT uniques(podName) WHERE createdKind = 'DaemonSet' AND podName LIKE '${page.value}%') FACET k8s.podName TIMESERIES LIMIT MAX"
            }
          ]
        })
      }

      # Container MEM Utilization per Pod (%)
      widget {
        title  = "Container MEM Utilization per Pod (%)"
        row    = 8
        column = 7
        width  = 6
        height = 3
        visualization_id = "viz.line"
        configuration = jsonencode(
        {
          "nrqlQueries": [
            {
              "accountId": var.NEW_RELIC_ACCOUNT_ID,
              "query": "FROM Metric SELECT average(k8s.container.memoryUsedBytes)/average(k8s.container.memoryLimitBytes)*100 WHERE k8s.podName IN (FROM K8sPodSample SELECT uniques(podName) WHERE createdKind = 'DaemonSet' AND podName LIKE '${page.value}%') AND k8s.containerName IN (FROM Metric SELECT uniques(k8s.containerName) WHERE k8s.clusterName = '${var.cluster_name}' AND k8s.container.memoryLimitBytes IS NOT NULL LIMIT MAX) FACET k8s.podName TIMESERIES LIMIT MAX"
            }
          ]
        })
      }

      # Container STO Usage per Pod (bytes)
      widget {
        title  = "Container STO Usage per Pod (bytes)"
        row    = 11
        column = 1
        width  = 6
        height = 3
        visualization_id = "viz.area"
        configuration = jsonencode(
        {
          "nrqlQueries": [
            {
              "accountId": var.NEW_RELIC_ACCOUNT_ID,
              "query": "FROM Metric SELECT average(k8s.container.fsUsedBytes) AS `sto` WHERE k8s.clusterName = '${var.cluster_name}' AND k8s.podName IN (FROM K8sPodSample SELECT uniques(podName) WHERE createdKind = 'DaemonSet' AND podName LIKE '${page.value}%') FACET k8s.podName TIMESERIES LIMIT MAX"
            }
          ]
        })
      }

      # Container STO Utilization per Pod (%)
      widget {
        title  = "Container STO Utilization per Pod (%)"
        row    = 11
        column = 7
        width  = 6
        height = 3
        visualization_id = "viz.line"
        configuration = jsonencode(
        {
          "nrqlQueries": [
            {
              "accountId": var.NEW_RELIC_ACCOUNT_ID,
              "query": "FROM Metric SELECT average(k8s.container.fsUsedBytes)/average(k8s.container.fsCapacityBytes)*100 WHERE k8s.podName IN (FROM K8sPodSample SELECT uniques(podName) WHERE createdKind = 'DaemonSet' AND podName LIKE '${page.value}%') AND k8s.containerName IN (FROM Metric SELECT uniques(k8s.containerName) WHERE k8s.clusterName = '${var.cluster_name}' AND k8s.container.fsCapacityBytes IS NOT NULL LIMIT MAX) FACET k8s.podName TIMESERIES LIMIT MAX"
            }
          ]
        })
      }
    }
  }
}
