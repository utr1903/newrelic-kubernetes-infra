##################
### Dashboards ###
##################

# Raw dashboard - Kubernetes Namespace Overview
resource "newrelic_one_dashboard_raw" "kubernetes_namespace_overview" {
  count = length(var.namespace_names)
  name  = "K8s Cluster ${var.cluster_name} | Namespace (${var.namespace_names[count.index]})"

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
        "text" : "## Namespace Overview\nThis page corresponds to the namespace ${var.namespace_names[count.index]} within the cluster ${var.cluster_name}."
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
            "query" : "FROM K8sContainerSample SELECT uniques(containerName) WHERE clusterName = '${var.cluster_name}' AND namespaceName = '${var.namespace_names[count.index]}' LIMIT MAX"
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
            "query" : "FROM K8sContainerSample SELECT uniqueCount(containerName) AS `Running` WHERE clusterName = '${var.cluster_name}' AND namespaceName = '${var.namespace_names[count.index]}' AND status = 'Running' LIMIT MAX"
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
            "query" : "FROM K8sContainerSample SELECT uniqueCount(containerName) AS `Not Running` WHERE clusterName = '${var.cluster_name}' AND namespaceName = '${var.namespace_names[count.index]}' AND status != 'Running' LIMIT MAX"
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
            "query" : "FROM K8sPodSample SELECT uniqueCount(podName) OR 0 AS `Running` WHERE clusterName = '${var.cluster_name}' AND namespaceName = '${var.namespace_names[count.index]}' AND status = 'Running' LIMIT MAX"
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
            "query" : "FROM K8sPodSample SELECT uniqueCount(podName) OR 0 AS `Pending` WHERE clusterName = '${var.cluster_name}' AND namespaceName = '${var.namespace_names[count.index]}' AND status = 'Pending' LIMIT MAX"
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
            "query" : "FROM K8sPodSample SELECT uniqueCount(podName) OR 0 AS `Failed` WHERE clusterName = '${var.cluster_name}' AND namespaceName = '${var.namespace_names[count.index]}' AND status = 'Failed' LIMIT MAX"
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
            "query" : "FROM K8sPodSample SELECT uniqueCount(podName) OR 0 AS `Unknown` WHERE clusterName = '${var.cluster_name}' AND namespaceName = '${var.namespace_names[count.index]}' AND status = 'Unknown' LIMIT MAX"
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
      visualization_id = "viz.area"
      configuration = jsonencode({
        "nrqlQueries" : [
          {
            "accountId" : var.NEW_RELIC_ACCOUNT_ID,
            "query" : "FROM (FROM K8sContainerSample SELECT max(cpuUsedCores)*1000 AS `cpu` WHERE clusterName = '${var.cluster_name}' AND namespaceName = '${var.namespace_names[count.index]}' FACET podName, containerID TIMESERIES LIMIT MAX) SELECT sum(`cpu`) TIMESERIES FACET podName LIMIT 10"
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
            "query" : "FROM (FROM K8sContainerSample SELECT max(cpuUsedCores) AS `usage`, max(cpuLimitCores) AS `limit` WHERE clusterName = '${var.cluster_name}' AND namespaceName = '${var.namespace_names[count.index]}' AND cpuLimitCores IS NOT NULL FACET podName TIMESERIES LIMIT MAX) SELECT sum(`usage`)/sum(`limit`)*100 FACET podName TIMESERIES LIMIT 10"
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
            "query" : "FROM (FROM K8sContainerSample SELECT max(memoryUsedBytes) AS `mem` WHERE clusterName = '${var.cluster_name}' AND namespaceName = '${var.namespace_names[count.index]}' FACET podName, containerID TIMESERIES LIMIT MAX) SELECT sum(`mem`) TIMESERIES FACET podName LIMIT 10"
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
            "query" : "FROM (FROM K8sContainerSample SELECT max(memoryUsedBytes) AS `usage`, max(memoryLimitBytes) AS `limit` WHERE clusterName = '${var.cluster_name}' AND namespaceName = '${var.namespace_names[count.index]}' AND memoryLimitBytes IS NOT NULL FACET podName TIMESERIES LIMIT MAX) SELECT sum(`usage`)/sum(`limit`)*100 FACET podName TIMESERIES LIMIT 10"
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
            "query" : "FROM (FROM K8sContainerSample SELECT max(fsUsedBytes) AS `sto` WHERE clusterName = '${var.cluster_name}' AND namespaceName = '${var.namespace_names[count.index]}' FACET podName, containerID TIMESERIES LIMIT MAX) SELECT sum(`sto`) TIMESERIES FACET podName LIMIT 10"
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
            "query" : "FROM (FROM K8sContainerSample SELECT max(fsUsedBytes) AS `usage`, max(fsCapacityBytes) AS `limit` WHERE clusterName = '${var.cluster_name}' AND namespaceName = '${var.namespace_names[count.index]}' AND fsCapacityBytes IS NOT NULL FACET podName TIMESERIES LIMIT MAX) SELECT sum(`usage`)/sum(`limit`)*100 FACET podName TIMESERIES LIMIT 10"
          }
        ]
      })
    }
  }
}
