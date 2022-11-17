##################
### Dashboards ###
##################

# Raw dashboard - Kubernetes Namespace Overview
resource "newrelic_one_dashboard_raw" "kubernetes_namespace_overview" {
  count = length(local.namespace_names)
  name  = "K8s Cluster ${var.cluster_name} | Namespace (${local.namespace_names[count.index]})"

  ##########################
  ### NAMESPACE OVERVIEW ###
  ##########################
  page {
    name = "Namespace Overview"

    # Page description
    widget {
      title            = "Page description"
      row              = 1
      column           = 1
      height           = 2
      width            = 4
      visualization_id = "viz.markdown"
      configuration = jsonencode({
        "text" : "## Namespace Overview\nThis page corresponds to the namespace ${local.namespace_names[count.index]} within the cluster ${var.cluster_name}."
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
            "query" : "FROM K8sContainerSample SELECT uniques(containerName) WHERE clusterName = '${var.cluster_name}' AND namespaceName = '${local.namespace_names[count.index]}' LIMIT MAX"
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
            "query" : "FROM K8sPodSample SELECT uniqueCount(podName) OR 0 AS `Running` WHERE clusterName = '${var.cluster_name}' AND namespaceName = '${local.namespace_names[count.index]}' AND status = 'Running' LIMIT MAX"
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
            "query" : "FROM K8sPodSample SELECT uniqueCount(podName) OR 0 AS `Pending` WHERE clusterName = '${var.cluster_name}' AND namespaceName = '${local.namespace_names[count.index]}' AND status = 'Pending' LIMIT MAX"
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
            "query" : "FROM K8sContainerSample SELECT uniqueCount(containerName) AS `Running` WHERE clusterName = '${var.cluster_name}' AND namespaceName = '${local.namespace_names[count.index]}' AND status = 'Running' LIMIT MAX"
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
            "query" : "FROM K8sContainerSample SELECT uniqueCount(containerName) AS `Not Running` WHERE clusterName = '${var.cluster_name}' AND namespaceName = '${local.namespace_names[count.index]}' AND status != 'Running' LIMIT MAX"
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
            "query" : "FROM K8sPodSample SELECT uniqueCount(podName) OR 0 AS `Failed` WHERE clusterName = '${var.cluster_name}' AND namespaceName = '${local.namespace_names[count.index]}' AND status = 'Failed' LIMIT MAX"
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
            "query" : "FROM K8sPodSample SELECT uniqueCount(podName) OR 0 AS `Unknown` WHERE clusterName = '${var.cluster_name}' AND namespaceName = '${local.namespace_names[count.index]}' AND status = 'Unknown' LIMIT MAX"
          }
        ]
      })
    }

    # Proportion of ready pods (%)
    widget {
      title            = "Proportion of ready pods (%)"
      row              = 5
      column           = 1
      height           = 2
      width            = 6
      visualization_id = "viz.bullet"
      configuration = jsonencode({
        "limit": 100,
        "nrqlQueries" : [
          {
            "accountId" : var.NEW_RELIC_ACCOUNT_ID,
            "query": "FROM K8sPodSample SELECT filter(uniqueCount(podName), WHERE isReady = 1) / uniqueCount(podName) * 100 AS `ready (%)` WHERE clusterName = '${var.cluster_name}' AND namespaceName = '${local.namespace_names[count.index]}'"
          }
        ]
      })
    }

    # Proportion of unschedulable pods (%)
    widget {
      title            = "Proportion of unschedulable pods (%)"
      row              = 5
      column           = 7
      height           = 2
      width            = 6
      visualization_id = "viz.bullet"
      configuration = jsonencode({
        "limit": 100,
        "nrqlQueries" : [
          {
            "accountId" : var.NEW_RELIC_ACCOUNT_ID,
            "query": "FROM K8sPodSample SELECT filter(uniqueCount(podName), WHERE isScheduled = 0) / uniqueCount(podName) * 100 AS `unscheduled (%)` WHERE clusterName = '${var.cluster_name}' AND namespaceName = '${local.namespace_names[count.index]}'"
          }
        ]
      })
    }

    # Top 10 CPU using pods (mcores)
    widget {
      title            = "Top 10 CPU using pods (mcores)"
      row              = 7
      column           = 1
      width            = 6
      height           = 3
      visualization_id = "viz.area"
      configuration = jsonencode({
        "nrqlQueries" : [
          {
            "accountId" : var.NEW_RELIC_ACCOUNT_ID,
            "query" : "FROM (FROM K8sContainerSample SELECT max(cpuUsedCores)*1000 AS `cpu` WHERE clusterName = '${var.cluster_name}' AND namespaceName = '${local.namespace_names[count.index]}' FACET podName, containerID TIMESERIES LIMIT MAX) SELECT sum(`cpu`) TIMESERIES FACET podName LIMIT 10"
          }
        ]
      })
    }

    # Top 10 CPU utilizing pods (%)
    widget {
      title            = "Top 10 CPU utilizing pods (%)"
      row              = 7
      column           = 7
      width            = 6
      height           = 3
      visualization_id = "viz.line"
      configuration = jsonencode({
        "nrqlQueries" : [
          {
            "accountId" : var.NEW_RELIC_ACCOUNT_ID,
            "query" : "FROM (FROM K8sContainerSample SELECT max(cpuUsedCores) AS `usage`, max(cpuLimitCores) AS `limit` WHERE clusterName = '${var.cluster_name}' AND namespaceName = '${local.namespace_names[count.index]}' AND cpuLimitCores IS NOT NULL FACET podName, containerID TIMESERIES LIMIT MAX) SELECT sum(`usage`)/sum(`limit`)*100 FACET podName TIMESERIES LIMIT 10"
          }
        ]
      })
    }

    # Top 10 CPU using containers (mcores)
    widget {
      title            = "Top 10 CPU using containers (mcores)"
      row              = 10
      column           = 1
      width            = 6
      height           = 3
      visualization_id = "viz.area"
      configuration = jsonencode({
        "nrqlQueries" : [
          {
            "accountId" : var.NEW_RELIC_ACCOUNT_ID,
            "query" : "FROM K8sContainerSample SELECT max(cpuUsedCores)*1000 AS `cpu` WHERE clusterName = '${var.cluster_name}' AND namespaceName = '${local.namespace_names[count.index]}' FACET containerName, podName TIMESERIES LIMIT 10"
          }
        ]
      })
    }

    # Top 10 CPU utilizing containers (%)
    widget {
      title            = "Top 10 CPU utilizing containers (%)"
      row              = 10
      column           = 7
      width            = 6
      height           = 3
      visualization_id = "viz.line"
      configuration = jsonencode({
        "nrqlQueries" : [
          {
            "accountId" : var.NEW_RELIC_ACCOUNT_ID,
            "query" : "FROM K8sContainerSample SELECT max(cpuUsedCores)/max(cpuLimitCores)*100 WHERE clusterName = '${var.cluster_name}' AND namespaceName = '${local.namespace_names[count.index]}' AND cpuLimitCores IS NOT NULL FACET containerName, podName TIMESERIES LIMIT 10"
          }
        ]
      })
    }

    # Top 10 MEM using pods (bytes)
    widget {
      title            = "Top 10 MEM using pods (bytes)"
      row              = 13
      column           = 1
      width            = 6
      height           = 3
      visualization_id = "viz.area"
      configuration = jsonencode({
        "nrqlQueries" : [
          {
            "accountId" : var.NEW_RELIC_ACCOUNT_ID,
            "query" : "FROM (FROM K8sContainerSample SELECT max(memoryUsedBytes) AS `mem` WHERE clusterName = '${var.cluster_name}' AND namespaceName = '${local.namespace_names[count.index]}' FACET podName, containerID TIMESERIES LIMIT MAX) SELECT sum(`mem`) TIMESERIES FACET podName LIMIT 10"
          }
        ]
      })
    }

    # Top 10 MEM utilizing pods (%)
    widget {
      title            = "Top 10 MEM utilizing pods (%)"
      row              = 13
      column           = 7
      width            = 6
      height           = 3
      visualization_id = "viz.line"
      configuration = jsonencode({
        "nrqlQueries" : [
          {
            "accountId" : var.NEW_RELIC_ACCOUNT_ID,
            "query" : "FROM (FROM K8sContainerSample SELECT max(memoryUsedBytes) AS `usage`, max(memoryLimitBytes) AS `limit` WHERE clusterName = '${var.cluster_name}' AND namespaceName = '${local.namespace_names[count.index]}' AND memoryLimitBytes IS NOT NULL FACET podName, containerID TIMESERIES LIMIT MAX) SELECT sum(`usage`)/sum(`limit`)*100 FACET podName TIMESERIES LIMIT 10"
          }
        ]
      })
    }

    # Top 10 MEM using containers (bytes)
    widget {
      title            = "Top 10 MEM using containers (bytes)"
      row              = 16
      column           = 1
      width            = 6
      height           = 3
      visualization_id = "viz.area"
      configuration = jsonencode({
        "nrqlQueries" : [
          {
            "accountId" : var.NEW_RELIC_ACCOUNT_ID,
            "query" : "FROM K8sContainerSample SELECT max(memoryUsedBytes) AS `mem` WHERE clusterName = '${var.cluster_name}' AND namespaceName = '${local.namespace_names[count.index]}' FACET containerName, podName TIMESERIES LIMIT 10"
          }
        ]
      })
    }

    # Top 10 MEM utilizing containers (%)
    widget {
      title            = "Top 10 MEM utilizing containers (%)"
      row              = 16
      column           = 7
      width            = 6
      height           = 3
      visualization_id = "viz.line"
      configuration = jsonencode({
        "nrqlQueries" : [
          {
            "accountId" : var.NEW_RELIC_ACCOUNT_ID,
            "query" : "FROM K8sContainerSample SELECT max(memoryUsedBytes)/max(memoryLimitBytes)*100 WHERE clusterName = '${var.cluster_name}' AND namespaceName = '${local.namespace_names[count.index]}' AND memoryLimitBytes IS NOT NULL FACET containerName, podName TIMESERIES LIMIT 10"
          }
        ]
      })
    }

    # Top 10 STO using pods (bytes)
    widget {
      title            = "Top 10 STO using pods (bytes)"
      row              = 19
      column           = 1
      width            = 6
      height           = 3
      visualization_id = "viz.area"
      configuration = jsonencode({
        "nrqlQueries" : [
          {
            "accountId" : var.NEW_RELIC_ACCOUNT_ID,
            "query" : "FROM (FROM K8sContainerSample SELECT max(fsUsedBytes) AS `sto` WHERE clusterName = '${var.cluster_name}' AND namespaceName = '${local.namespace_names[count.index]}' FACET podName, containerID TIMESERIES LIMIT MAX) SELECT sum(`sto`) TIMESERIES FACET podName LIMIT 10"
          }
        ]
      })
    }

    # Top 10 STO utilizing pods (%)
    widget {
      title            = "Top 10 STO utilizing pods (%)"
      row              = 19
      column           = 7
      width            = 6
      height           = 3
      visualization_id = "viz.line"
      configuration = jsonencode({
        "nrqlQueries" : [
          {
            "accountId" : var.NEW_RELIC_ACCOUNT_ID,
            "query" : "FROM (FROM K8sContainerSample SELECT max(fsUsedBytes) AS `usage`, max(fsCapacityBytes) AS `limit` WHERE clusterName = '${var.cluster_name}' AND namespaceName = '${local.namespace_names[count.index]}' AND fsCapacityBytes IS NOT NULL FACET podName, containerID TIMESERIES LIMIT MAX) SELECT sum(`usage`)/sum(`limit`)*100 FACET podName TIMESERIES LIMIT 10"
          }
        ]
      })
    }

    # Top 10 STO using containers (bytes)
    widget {
      title            = "Top 10 STO using containers (bytes)"
      row              = 22
      column           = 1
      width            = 6
      height           = 3
      visualization_id = "viz.area"
      configuration = jsonencode({
        "nrqlQueries" : [
          {
            "accountId" : var.NEW_RELIC_ACCOUNT_ID,
            "query" : "FROM K8sContainerSample SELECT max(fsUsedBytes) AS `sto` WHERE clusterName = '${var.cluster_name}' AND namespaceName = '${local.namespace_names[count.index]}' FACET containerName, podName TIMESERIES LIMIT 10"
          }
        ]
      })
    }

    # Top 10 STO utilizing containers (%)
    widget {
      title            = "Top 10 STO utilizing containers (%)"
      row              = 22
      column           = 7
      width            = 6
      height           = 3
      visualization_id = "viz.line"
      configuration = jsonencode({
        "nrqlQueries" : [
          {
            "accountId" : var.NEW_RELIC_ACCOUNT_ID,
            "query" : "FROM K8sContainerSample SELECT max(fsUsedBytes)/max(fsCapacityBytes)*100 WHERE clusterName = '${var.cluster_name}' AND namespaceName = '${local.namespace_names[count.index]}' AND fsCapacityBytes IS NOT NULL FACET containerName, podName TIMESERIES LIMIT 10"
          }
        ]
      })
    }
  }
}
