##################
### Dashboards ###
##################

# Dashboard - Kubernetes Statefulset Overview
resource "newrelic_one_dashboard" "kubernetes_statefulset_overview" {
  name = "K8s ${var.cluster_name} | 05_Statefulsets"

  page {
    name = "Statefulsets"

    # Page description
    widget_markdown {
      title  = "Page description"
      row    = 1
      column = 1
      width  = 4
      height = 2

      text = "## Statefulset Overview\nThis page corresponds to the statefulsets within the cluster ${var.cluster_name}."
    }

    # Containers
    widget_table {
      title  = "Containers"
      row    = 1
      column = 5
      width  = 4
      height = 4

      nrql_query {
        account_id = var.NEW_RELIC_ACCOUNT_ID
        query      = "FROM K8sContainerSample SELECT uniques(containerName) WHERE podName IN (FROM K8sPodSample SELECT uniques(podName) WHERE clusterName = '${var.cluster_name}' AND namespaceName IN ({{namespaces}}) AND createdKind = 'StatefulSet' AND podName IN (FROM K8sPodSample SELECT uniques(podName) WHERE substring(podName, 0, length(podName)-(1)) IN ({{statefulsets}}) LIMIT MAX) LIMIT MAX) LIMIT MAX"
      }
    }

    # Pod (Running)
    widget_billboard {
      title  = "Pod (Running)"
      row    = 1
      column = 9
      width  = 2
      height = 2

      nrql_query {
        account_id = var.NEW_RELIC_ACCOUNT_ID
        query      = "FROM K8sPodSample SELECT uniqueCount(podName) OR 0 AS `Running` WHERE clusterName = '${var.cluster_name}' AND namespaceName IN ({{namespaces}}) AND createdKind = 'StatefulSet' AND podName IN (FROM K8sPodSample SELECT uniques(podName) WHERE substring(podName, 0, length(podName)-(1)) IN ({{statefulsets}}) LIMIT MAX) AND status = 'Running' LIMIT MAX"
      }
    }

    # Pod (Pending)
    widget_billboard {
      title  = "Pod (Pending)"
      row    = 1
      column = 11
      width  = 2
      height = 2

      nrql_query {
        account_id = var.NEW_RELIC_ACCOUNT_ID
        query      = "FROM K8sPodSample SELECT uniqueCount(podName) OR 0 AS `Pending` WHERE clusterName = '${var.cluster_name}' AND namespaceName IN ({{namespaces}}) AND createdKind = 'StatefulSet' AND podName IN (FROM K8sPodSample SELECT uniques(podName) WHERE substring(podName, 0, length(podName)-(1)) IN ({{statefulsets}}) LIMIT MAX) AND status = 'Pending' LIMIT MAX"
      }
    }

    # Container (Running)
    widget_billboard {
      title  = "Container (Running)"
      row    = 3
      column = 1
      width  = 2
      height = 2

      nrql_query {
        account_id = var.NEW_RELIC_ACCOUNT_ID
        query      = "FROM K8sContainerSample SELECT uniqueCount(containerName) AS `Running` WHERE clusterName = '${var.cluster_name}' AND namespaceName IN ({{namespaces}}) AND podName IN (FROM K8sPodSample SELECT uniques(podName) WHERE createdKind = 'StatefulSet' AND substring(podName, 0, length(podName)-(1)) IN ({{statefulsets}}) LIMIT MAX) AND status = 'Running' LIMIT MAX"
      }
    }

    # Container (Terminated/Unknown)
    widget_billboard {
      title  = "Container (Terminated/Unknown)"
      row    = 3
      column = 3
      width  = 2
      height = 2

      nrql_query {
        account_id = var.NEW_RELIC_ACCOUNT_ID
        query      = "FROM K8sContainerSample SELECT uniqueCount(containerName) AS `Not Running` WHERE clusterName = '${var.cluster_name}' AND namespaceName IN ({{namespaces}}) AND podName IN (FROM K8sPodSample SELECT uniques(podName) WHERE createdKind = 'StatefulSet' AND substring(podName, 0, length(podName)-(1)) IN ({{statefulsets}}) LIMIT MAX) AND status != 'Running' LIMIT MAX"
      }
    }

    # Pod (Failed)
    widget_billboard {
      title  = "Pod (Failed)"
      row    = 3
      column = 9
      width  = 2
      height = 2

      nrql_query {
        account_id = var.NEW_RELIC_ACCOUNT_ID
        query      = "FROM K8sPodSample SELECT uniqueCount(podName) OR 0 AS `Failed` WHERE clusterName = '${var.cluster_name}' AND namespaceName IN ({{namespaces}}) AND createdKind = 'StatefulSet' AND podName IN (FROM K8sPodSample SELECT uniques(podName) WHERE substring(podName, 0, length(podName)-(1)) IN ({{statefulsets}}) LIMIT MAX) AND status = 'Failed' LIMIT MAX"
      }
    }

    # Pod (Unknown)
    widget_billboard {
      title  = "Pod (Unknown)"
      row    = 3
      column = 11
      width  = 2
      height = 2

      nrql_query {
        account_id = var.NEW_RELIC_ACCOUNT_ID
        query      = "FROM K8sPodSample SELECT uniqueCount(podName) OR 0 AS `Unknown` WHERE clusterName = '${var.cluster_name}' AND namespaceName IN ({{namespaces}}) AND createdKind = 'StatefulSet' AND podName IN (FROM K8sPodSample SELECT uniques(podName) WHERE substring(podName, 0, length(podName)-(1)) IN ({{statefulsets}}) LIMIT MAX) AND status = 'Unknown' LIMIT MAX"
      }
    }

    # Proportion of ready pods (%)
    widget_bullet {
      title  = "Proportion of ready pods (%)"
      row    = 5
      column = 1
      width  = 6
      height = 2

      limit = 100
      nrql_query {
        account_id = var.NEW_RELIC_ACCOUNT_ID
        query      = "FROM K8sPodSample SELECT filter(uniqueCount(podName), WHERE isReady = 1) / uniqueCount(podName) * 100 AS `ready (%)` WHERE clusterName = '${var.cluster_name}' AND namespaceName IN ({{namespaces}}) AND createdKind = 'StatefulSet' AND podName IN (FROM K8sPodSample SELECT uniques(podName) WHERE substring(podName, 0, length(podName)-(1)) IN ({{statefulsets}}) LIMIT MAX) LIMIT MAX"
      }
    }

    # Proportion of unschedulable pods (%)
    widget_bullet {
      title  = "Proportion of unschedulable pods (%)"
      row    = 5
      column = 7
      width  = 6
      height = 2

      limit = 100
      nrql_query {
        account_id = var.NEW_RELIC_ACCOUNT_ID
        query      = "FROM K8sPodSample SELECT filter(uniqueCount(podName), WHERE isReady = 1) / uniqueCount(podName) * 100 AS `ready (%)` WHERE clusterName = '${var.cluster_name}' AND namespaceName IN ({{namespaces}}) AND createdKind = 'StatefulSet' AND podName IN (FROM K8sPodSample SELECT uniques(podName) WHERE substring(podName, 0, length(podName)-(1)) IN ({{statefulsets}}) LIMIT MAX) LIMIT MAX"
      }
    }

    # Top 10 CPU using pods (mcores)
    widget_area {
      title  = "Top 10 CPU using pods (mcores)"
      row    = 7
      column = 1
      width  = 6
      height = 3

      nrql_query {
        account_id = var.NEW_RELIC_ACCOUNT_ID
        query      = "FROM (FROM K8sContainerSample SELECT max(cpuUsedCores)*1000 AS `cpu` WHERE clusterName = '${var.cluster_name}' AND namespaceName IN ({{namespaces}}) AND podName IN (FROM K8sPodSample SELECT uniques(podName) WHERE createdKind = 'StatefulSet' AND podName IN (FROM K8sPodSample SELECT uniques(podName) WHERE substring(podName, 0, length(podName)-(1)) IN ({{statefulsets}}) LIMIT MAX) LIMIT MAX) FACET podName, containerID TIMESERIES LIMIT MAX) SELECT sum(`cpu`) FACET podName TIMESERIES LIMIT 10"
      }
    }

    # Top 10 CPU utilizing pods (%)
    widget_line {
      title  = "Top 10 CPU utilizing pods (%)"
      row    = 7
      column = 7
      width  = 6
      height = 3

      nrql_query {
        account_id = var.NEW_RELIC_ACCOUNT_ID
        query      = "FROM (FROM K8sContainerSample SELECT max(cpuUsedCores) AS `usage`, max(cpuLimitCores) AS `limit` WHERE clusterName = '${var.cluster_name}' AND namespaceName IN ({{namespaces}}) AND podName IN (FROM K8sPodSample SELECT uniques(podName) WHERE createdKind = 'StatefulSet' AND podName IN (FROM K8sPodSample SELECT uniques(podName) WHERE substring(podName, 0, length(podName)-(1)) IN ({{statefulsets}}) LIMIT MAX) LIMIT MAX) AND cpuLimitCores IS NOT NULL FACET podName, containerID TIMESERIES LIMIT MAX) SELECT sum(`usage`)/sum(`limit`)*100 FACET podName TIMESERIES LIMIT 10"
      }
    }

    # Top 10 CPU using containers (mcores)
    widget_area {
      title  = "Top 10 CPU using containers (mcores)"
      row    = 10
      column = 1
      width  = 6
      height = 3

      nrql_query {
        account_id = var.NEW_RELIC_ACCOUNT_ID
        query      = "FROM K8sContainerSample SELECT max(cpuUsedCores)*1000 AS `cpu` WHERE clusterName = '${var.cluster_name}' AND namespaceName IN ({{namespaces}}) AND podName IN (FROM K8sPodSample SELECT uniques(podName) WHERE createdKind = 'StatefulSet' AND podName IN (FROM K8sPodSample SELECT uniques(podName) WHERE substring(podName, 0, length(podName)-(1)) IN ({{statefulsets}}) LIMIT MAX) LIMIT MAX) FACET containerName, podName TIMESERIES LIMIT 10"
      }
    }

    # Top 10 CPU utilizing containers (%)
    widget_line {
      title  = "Top 10 CPU utilizing containers (%)"
      row    = 10
      column = 7
      width  = 6
      height = 3

      nrql_query {
        account_id = var.NEW_RELIC_ACCOUNT_ID
        query      = "FROM K8sContainerSample SELECT max(cpuUsedCores)/max(cpuLimitCores)*100 WHERE clusterName = '${var.cluster_name}' AND namespaceName IN ({{namespaces}}) AND podName IN (FROM K8sPodSample SELECT uniques(podName) WHERE createdKind = 'StatefulSet' AND podName IN (FROM K8sPodSample SELECT uniques(podName) WHERE substring(podName, 0, length(podName)-(1)) IN ({{statefulsets}}) LIMIT MAX) LIMIT MAX) AND cpuLimitCores IS NOT NULL FACET containerName, podName TIMESERIES LIMIT 10"
      }
    }

    # Top 10 MEM using pods (bytes)
    widget_area {
      title  = "Top 10 MEM using pods (bytes)"
      row    = 13
      column = 1
      width  = 6
      height = 3

      nrql_query {
        account_id = var.NEW_RELIC_ACCOUNT_ID
        query      = "FROM (FROM K8sContainerSample SELECT max(memoryUsedBytes) AS `mem` WHERE clusterName = '${var.cluster_name}' AND namespaceName IN ({{namespaces}}) AND podName IN (FROM K8sPodSample SELECT uniques(podName) WHERE createdKind = 'StatefulSet' AND podName IN (FROM K8sPodSample SELECT uniques(podName) WHERE substring(podName, 0, length(podName)-(1)) IN ({{statefulsets}}) LIMIT MAX) LIMIT MAX) FACET podName, containerID TIMESERIES LIMIT MAX) SELECT sum(`mem`) FACET podName TIMESERIES LIMIT 10"
      }
    }

    # Top 10 MEM utilizing pods (%)
    widget_line {
      title  = "Top 10 MEM utilizing pods (%)"
      row    = 13
      column = 7
      width  = 6
      height = 3

      nrql_query {
        account_id = var.NEW_RELIC_ACCOUNT_ID
        query      = "FROM (FROM K8sContainerSample SELECT max(memoryUsedBytes) AS `usage`, max(memoryLimitBytes) AS `limit` WHERE clusterName = '${var.cluster_name}' AND namespaceName IN ({{namespaces}}) AND podName IN (FROM K8sPodSample SELECT uniques(podName) WHERE createdKind = 'StatefulSet' AND podName IN (FROM K8sPodSample SELECT uniques(podName) WHERE substring(podName, 0, length(podName)-(1)) IN ({{statefulsets}}) LIMIT MAX) LIMIT MAX) AND memoryLimitBytes IS NOT NULL FACET podName, containerID TIMESERIES LIMIT MAX) SELECT sum(`usage`)/sum(`limit`)*100 FACET podName TIMESERIES LIMIT 10"
      }
    }

    # Top 10 MEM using containers (bytes)
    widget_area {
      title  = "Top 10 MEM using containers (bytes)"
      row    = 16
      column = 1
      width  = 6
      height = 3

      nrql_query {
        account_id = var.NEW_RELIC_ACCOUNT_ID
        query      = "FROM K8sContainerSample SELECT max(memoryUsedBytes) AS `mem` WHERE clusterName = '${var.cluster_name}' AND namespaceName IN ({{namespaces}}) AND podName IN (FROM K8sPodSample SELECT uniques(podName) WHERE createdKind = 'StatefulSet' AND podName IN (FROM K8sPodSample SELECT uniques(podName) WHERE substring(podName, 0, length(podName)-(1)) IN ({{statefulsets}}) LIMIT MAX) LIMIT MAX) FACET containerName, podName TIMESERIES LIMIT 10"
      }
    }

    # Top 10 MEM utilizing containers (%)
    widget_line {
      title  = "Top 10 MEM utilizing containers (%)"
      row    = 16
      column = 7
      width  = 6
      height = 3

      nrql_query {
        account_id = var.NEW_RELIC_ACCOUNT_ID
        query      = "FROM K8sContainerSample SELECT max(memoryUsedBytes)/max(memoryLimitBytes)*100 WHERE clusterName = '${var.cluster_name}' AND namespaceName IN ({{namespaces}}) AND podName IN (FROM K8sPodSample SELECT uniques(podName) WHERE createdKind = 'StatefulSet' AND podName IN (FROM K8sPodSample SELECT uniques(podName) WHERE substring(podName, 0, length(podName)-(1)) IN ({{statefulsets}}) LIMIT MAX) LIMIT MAX) AND memoryLimitBytes IS NOT NULL FACET containerName, podName TIMESERIES LIMIT 10"
      }
    }

    # Top 10 STO using pods (bytes)
    widget_area {
      title  = "Top 10 STO using pods (bytes)"
      row    = 19
      column = 1
      width  = 6
      height = 3

      nrql_query {
        account_id = var.NEW_RELIC_ACCOUNT_ID
        query      = "FROM (FROM K8sContainerSample SELECT max(fsUsedBytes) AS `sto` WHERE clusterName = '${var.cluster_name}' AND namespaceName IN ({{namespaces}}) AND podName IN (FROM K8sPodSample SELECT uniques(podName) WHERE createdKind = 'StatefulSet' AND podName IN (FROM K8sPodSample SELECT uniques(podName) WHERE substring(podName, 0, length(podName)-(1)) IN ({{statefulsets}}) LIMIT MAX) LIMIT MAX) FACET podName, containerID TIMESERIES LIMIT MAX) SELECT sum(`sto`) FACET podName TIMESERIES LIMIT 10"
      }
    }

    # Top 10 STO utilizing pods (%)
    widget_line {
      title  = "Top 10 STO utilizing pods (%)"
      row    = 19
      column = 7
      width  = 6
      height = 3

      nrql_query {
        account_id = var.NEW_RELIC_ACCOUNT_ID
        query      = "FROM (FROM K8sContainerSample SELECT max(fsUsedBytes) AS `usage`, max(fsCapacityBytes) AS `limit` WHERE clusterName = '${var.cluster_name}' AND namespaceName IN ({{namespaces}}) AND podName IN (FROM K8sPodSample SELECT uniques(podName) WHERE createdKind = 'StatefulSet' AND podName IN (FROM K8sPodSample SELECT uniques(podName) WHERE substring(podName, 0, length(podName)-(1)) IN ({{statefulsets}}) LIMIT MAX) LIMIT MAX) AND fsCapacityBytes IS NOT NULL FACET podName, containerID TIMESERIES LIMIT MAX) SELECT sum(`usage`)/sum(`limit`)*100 FACET podName TIMESERIES LIMIT 10"
      }
    }

    # Top 10 STO using containers (bytes)
    widget_area {
      title  = "Top 10 STO using containers (bytes)"
      row    = 22
      column = 1
      width  = 6
      height = 3

      nrql_query {
        account_id = var.NEW_RELIC_ACCOUNT_ID
        query      = "FROM K8sContainerSample SELECT max(fsUsedBytes) AS `sto` WHERE clusterName = '${var.cluster_name}' AND namespaceName IN ({{namespaces}}) AND podName IN (FROM K8sPodSample SELECT uniques(podName) WHERE createdKind = 'StatefulSet' AND podName IN (FROM K8sPodSample SELECT uniques(podName) WHERE substring(podName, 0, length(podName)-(1)) IN ({{statefulsets}}) LIMIT MAX) LIMIT MAX) FACET containerName, podName TIMESERIES LIMIT 10"
      }
    }

    # Top 10 STO utilizing containers (%)
    widget_line {
      title  = "Top 10 STO utilizing containers (%)"
      row    = 22
      column = 7
      width  = 6
      height = 3

      nrql_query {
        account_id = var.NEW_RELIC_ACCOUNT_ID
        query      = "FROM (FROM K8sContainerSample SELECT max(fsUsedBytes) AS `usage`, max(fsCapacityBytes) AS `limit` WHERE clusterName = '${var.cluster_name}' AND namespaceName IN ({{namespaces}}) AND podName IN (FROM K8sPodSample SELECT uniques(podName) WHERE createdKind = 'StatefulSet' AND podName IN (FROM K8sPodSample SELECT uniques(podName) WHERE substring(podName, 0, length(podName)-(1)) IN ({{statefulsets}}) LIMIT MAX) LIMIT MAX) AND fsCapacityBytes IS NOT NULL FACET podName, containerID TIMESERIES LIMIT MAX) SELECT sum(`usage`)/sum(`limit`)*100 FACET podName TIMESERIES LIMIT 10"
      }
    }
  }

  # Namespaces
  variable {
    name  = "namespaces"
    title = "Namespaces"
    type  = "nrql"

    default_values       = ["*"]
    replacement_strategy = "default"
    is_multi_selection   = true

    nrql_query {
      account_ids = [var.NEW_RELIC_ACCOUNT_ID]
      query       = "FROM K8sPodSample SELECT uniques(namespaceName) WHERE clusterName = '${var.cluster_name}'"
    }
  }

  # Statefulsets
  variable {
    name  = "statefulsets"
    title = "Statefulsets"
    type  = "nrql"

    default_values       = ["*"]
    replacement_strategy = "default"
    is_multi_selection   = true

    nrql_query {
      account_ids = [var.NEW_RELIC_ACCOUNT_ID]
      query       = "FROM K8sStatefulSample SELECT uniques(statefulsetName) WHERE clusterName = '${var.cluster_name}'"
    }
  }
}
