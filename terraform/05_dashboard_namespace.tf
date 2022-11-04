##################
### Dashboards ###
##################

# Raw dashboard - Kubernetes Namespace Overview
resource "newrelic_one_dashboard_raw" "kubernetes_namespace_overview" {
  count = length(var.namespace_names)
  name = "K8s Cluster ${var.cluster_name} | Namespace (${var.namespace_names[count.index]})"

  ##########################
  ### NAMESPACE OVERVIEW ###
  ##########################
  page {
    name = "Namespace Overview"

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
        "text": "## Namespace Overview\nThis page corresponds to the namespace ${var.namespace_names[count.index]} within the cluster ${var.cluster_name}."
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
            "query": "FROM K8sContainerSample SELECT uniques(containerName) WHERE clusterName = '${var.cluster_name}' AND namespaceName = '${var.namespace_names[count.index]}' LIMIT MAX"
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
            "query": "FROM K8sContainerSample SELECT uniqueCount(containerName) AS `Running` WHERE clusterName = '${var.cluster_name}' AND namespaceName = '${var.namespace_names[count.index]}' AND status = 'Running' LIMIT MAX"
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
            "query": "FROM K8sContainerSample SELECT uniqueCount(containerName) AS `Not Running` WHERE clusterName = '${var.cluster_name}' AND namespaceName = '${var.namespace_names[count.index]}' AND status != 'Running' LIMIT MAX"
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
            "query": "FROM K8sPodSample SELECT uniqueCount(podName) OR 0 WHERE clusterName = '${var.cluster_name}' AND namespaceName = '${var.namespace_names[count.index]}' AND status = 'Running' LIMIT MAX"
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
            "query": "FROM K8sPodSample SELECT uniqueCount(podName) OR 0 WHERE clusterName = '${var.cluster_name}' AND namespaceName = '${var.namespace_names[count.index]}' AND status = 'Pending' LIMIT MAX"
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
            "query": "FROM K8sPodSample SELECT uniqueCount(podName) OR 0 WHERE clusterName = '${var.cluster_name}' AND namespaceName = '${var.namespace_names[count.index]}' AND status = 'Failed' LIMIT MAX"
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
            "query": "FROM K8sPodSample SELECT uniqueCount(podName) OR 0 WHERE clusterName = '${var.cluster_name}' AND namespaceName = '${var.namespace_names[count.index]}' AND status = 'Unknown' LIMIT MAX"
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
            "query": "FROM (FROM Metric SELECT average(k8s.container.cpuUsedCores)*1000 AS `cpu` WHERE k8s.clusterName = '${var.cluster_name}' AND namespaceName = '${var.namespace_names[count.index]}' FACET k8s.podName TIMESERIES LIMIT MAX) SELECT sum(cpu) FACET podName TIMESERIES LIMIT MAX"
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
            "query": "FROM (FROM Metric SELECT average(k8s.container.cpuUsedCores) AS `usage`, average(k8s.container.cpuLimitCores) AS `limit` WHERE k8s.containerName IN (FROM Metric SELECT uniques(k8s.containerName) WHERE k8s.clusterName = '${var.cluster_name}' AND namespaceName = '${var.namespace_names[count.index]}' AND k8s.container.cpuLimitCores IS NOT NULL LIMIT MAX) FACET k8s.podName TIMESERIES LIMIT MAX) SELECT sum(`usage`)/sum(`limit`)*100 FACET podName TIMESERIES LIMIT MAX"
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
            "query": "FROM (FROM Metric SELECT average(k8s.container.memoryUsedBytes) AS `mem` WHERE k8s.clusterName = '${var.cluster_name}' AND namespaceName = '${var.namespace_names[count.index]}' FACET k8s.podName TIMESERIES LIMIT MAX) SELECT sum(mem) FACET podName TIMESERIES LIMIT MAX"
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
            "query": "FROM (FROM Metric SELECT average(k8s.container.memoryUsedBytes) AS `usage`, average(k8s.container.memoryLimitBytes) AS `limit` WHERE k8s.containerName IN (FROM Metric SELECT uniques(k8s.containerName) WHERE k8s.clusterName = '${var.cluster_name}' AND namespaceName = '${var.namespace_names[count.index]}' AND k8s.container.memoryLimitBytes IS NOT NULL LIMIT MAX) FACET k8s.podName TIMESERIES LIMIT MAX) SELECT sum(`usage`)/sum(`limit`)*100 FACET podName TIMESERIES LIMIT MAX"
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
            "query": "FROM (FROM Metric SELECT average(k8s.container.fsUsedBytes) AS `mem` WHERE k8s.clusterName = '${var.cluster_name}' AND namespaceName = '${var.namespace_names[count.index]}' FACET k8s.podName TIMESERIES LIMIT MAX) SELECT sum(mem) FACET podName TIMESERIES"
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
            "query": "FROM (FROM Metric SELECT average(k8s.container.fsUsedBytes) AS `usage`, average(k8s.container.fsCapacityBytes) AS `limit` WHERE k8s.containerName IN (FROM Metric SELECT uniques(k8s.containerName) WHERE k8s.clusterName = '${var.cluster_name}' AND namespaceName = '${var.namespace_names[count.index]}' AND k8s.container.fsCapacityBytes IS NOT NULL LIMIT MAX) FACET k8s.podName TIMESERIES LIMIT MAX) SELECT sum(`usage`)/sum(`limit`)*100 FACET podName TIMESERIES LIMIT MAX"
          }
        ]
      })
    }
  }
}
