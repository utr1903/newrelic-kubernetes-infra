##################
### Dashboards ###
##################

# Raw dashboard - Kubernetes Cluster Overview
resource "newrelic_one_dashboard_raw" "kubernetes_cluster_overview" {
  name = "K8s Cluster ${var.cluster_name}"

  #####################
  ### NODE OVERVIEW ###
  #####################
  page {
    name = "Node Overview"

    # Page description
    widget {
      title            = "Page description"
      row              = 1
      column           = 1
      height           = 2
      width            = 4
      visualization_id = "viz.markdown"
      configuration = jsonencode({
        "text" : "## Node Overview\nTo be able to visualize every widget properly, New Relic infrastructure agent should be installed."
      })
    }

    # Node to pod map
    widget {
      title            = "Node to pod map"
      row              = 1
      column           = 5
      height           = 5
      width            = 4
      visualization_id = "viz.table"
      configuration = jsonencode({
        "nrqlQueries" : [
          {
            "accountId" : var.NEW_RELIC_ACCOUNT_ID,
            "query" : "FROM K8sPodSample SELECT uniques(concat(nodeName, ' -> ', podName)) AS `Node -> Pod` WHERE clusterName = '${var.cluster_name}'"
          }
        ]
      })
    }

    # Number of namespaces by nodes
    widget {
      title            = "Number of namespaces by nodes"
      row              = 1
      column           = 9
      height           = 2
      width            = 4
      visualization_id = "viz.line"
      configuration = jsonencode({
        "nrqlQueries" : [
          {
            "accountId" : var.NEW_RELIC_ACCOUNT_ID,
            "query" : "FROM K8sPodSample SELECT uniqueCount(namespaceName) WHERE clusterName = '${var.cluster_name}' FACET nodeName TIMESERIES LIMIT MAX"
          }
        ]
      })
    }

    # Node capacities
    widget {
      title            = "Node capacities"
      row              = 2
      column           = 1
      height           = 3
      width            = 4
      visualization_id = "viz.table"
      configuration = jsonencode({
        "nrqlQueries" : [
          {
            "accountId" : var.NEW_RELIC_ACCOUNT_ID,
            "query" : "FROM K8sNodeSample SELECT max(capacityCpuCores) AS 'CPU (cores)', max(capacityMemoryBytes)/1024/1024/1024 AS 'MEM (GiB)' WHERE clusterName = '${var.cluster_name}' FACET nodeName"
          }
        ]
      })
    }

    # Number of pods by nodes
    widget {
      title            = "Number of pods by nodes"
      row              = 2
      column           = 9
      height           = 3
      width            = 4
      visualization_id = "viz.line"
      configuration = jsonencode({
        "nrqlQueries" : [
          {
            "accountId" : var.NEW_RELIC_ACCOUNT_ID,
            "query" : "FROM K8sPodSample SELECT uniqueCount(podName) WHERE clusterName = '${var.cluster_name}' FACET nodeName TIMESERIES LIMIT MAX"
          }
        ]
      })
    }

    # Proportion of ready nodes (%)
    widget {
      title            = "Proportion of ready nodes (%)"
      row              = 6
      column           = 1
      height           = 2
      width            = 6
      visualization_id = "viz.bullet"
      configuration = jsonencode({
        "limit" : 100,
        "nrqlQueries" : [
          {
            "accountId" : var.NEW_RELIC_ACCOUNT_ID,
            "query" : "FROM K8sNodeSample SELECT filter(uniqueCount(nodeName), WHERE condition.Ready = 1)/uniqueCount(nodeName)*100 AS `ready (%)` WHERE clusterName = '${var.cluster_name}'"
          }
        ]
      })
    }

    # Proportion of unschedulable nodes (%)
    widget {
      title            = "Proportion of unschedulable nodes (%)"
      row              = 6
      column           = 7
      height           = 2
      width            = 6
      visualization_id = "viz.bullet"
      configuration = jsonencode({
        "limit" : 100,
        "nrqlQueries" : [
          {
            "accountId" : var.NEW_RELIC_ACCOUNT_ID,
            "query" : "FROM K8sNodeSample SELECT filter(uniqueCount(nodeName), WHERE unschedulable = 1)/uniqueCount(nodeName)*100 AS `unschedulable (%)` WHERE clusterName = '${var.cluster_name}'"
          }
        ]
      })
    }

    # Node CPU usage (mcores)
    widget {
      title            = "Node CPU usage (mcores)"
      row              = 8
      column           = 1
      height           = 3
      width            = 6
      visualization_id = "viz.area"
      configuration = jsonencode({
        "nrqlQueries" : [
          {
            "accountId" : var.NEW_RELIC_ACCOUNT_ID,
            "query" : "FROM K8sNodeSample SELECT max(cpuUsedCores)*1000 AS `CPU (mcores)` WHERE clusterName = '${var.cluster_name}' FACET nodeName TIMESERIES LIMIT MAX"
          }
        ]
      })
    }

    # Node CPU utilization (%)
    widget {
      title            = "Node CPU utilization (%)"
      row              = 8
      column           = 7
      height           = 3
      width            = 6
      visualization_id = "viz.line"
      configuration = jsonencode({
        "nrqlQueries" : [
          {
            "accountId" : var.NEW_RELIC_ACCOUNT_ID,
            "query" : "FROM K8sNodeSample SELECT max(cpuUsedCores)/max(capacityCpuCores)*100 WHERE clusterName = '${var.cluster_name}' FACET nodeName TIMESERIES LIMIT MAX"
          }
        ]
      })
    }

    # Node MEM usage (bytes)
    widget {
      title            = "Node MEM usage (bytes)"
      row              = 11
      column           = 1
      height           = 3
      width            = 6
      visualization_id = "viz.area"
      configuration = jsonencode({
        "nrqlQueries" : [
          {
            "accountId" : var.NEW_RELIC_ACCOUNT_ID,
            "query" : "FROM K8sNodeSample SELECT max(memoryUsedBytes) AS `MEM (bytes)` WHERE clusterName = '${var.cluster_name}' FACET nodeName TIMESERIES LIMIT MAX"
          }
        ]
      })
    }

    # Node MEM utilization (%)
    widget {
      title            = "Node MEM utilization (%)"
      row              = 11
      column           = 7
      height           = 3
      width            = 6
      visualization_id = "viz.line"
      configuration = jsonencode({
        "nrqlQueries" : [
          {
            "accountId" : var.NEW_RELIC_ACCOUNT_ID,
            "query" : "FROM K8sNodeSample SELECT max(memoryUsedBytes)/max(capacityMemoryBytes)*100 WHERE clusterName = '${var.cluster_name}' FACET nodeName TIMESERIES LIMIT MAX"
          }
        ]
      })
    }

    # Node STO usage (bytes)
    widget {
      title            = "Node STO usage (bytes)"
      row              = 14
      column           = 1
      height           = 3
      width            = 6
      visualization_id = "viz.area"
      configuration = jsonencode({
        "nrqlQueries" : [
          {
            "accountId" : var.NEW_RELIC_ACCOUNT_ID,
            "query" : "FROM K8sNodeSample SELECT max(fsUsedBytes) AS `STO (bytes)` WHERE clusterName = '${var.cluster_name}' FACET nodeName TIMESERIES LIMIT MAX"
          }
        ]
      })
    }

    # Node STO utilization (%)
    widget {
      title            = "Node STO utilization (%)"
      row              = 14
      column           = 7
      height           = 3
      width            = 6
      visualization_id = "viz.line"
      configuration = jsonencode({
        "nrqlQueries" : [
          {
            "accountId" : var.NEW_RELIC_ACCOUNT_ID,
            "query" : "FROM K8sNodeSample SELECT max(fsUsedBytes)/max(fsCapacityBytes)*100 WHERE clusterName = '${var.cluster_name}' FACET nodeName TIMESERIES LIMIT MAX"
          }
        ]
      })
    }
  }

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
        "text" : "## Namespace Overview\nTo be able to visualize every widget properly, New Relic infrastructure agent should be installed."
      })
    }

    # Namespaces
    widget {
      title            = "Namespaces"
      row              = 1
      column           = 5
      height           = 2
      width            = 2
      visualization_id = "viz.table"
      configuration = jsonencode({
        "nrqlQueries" : [
          {
            "accountId" : var.NEW_RELIC_ACCOUNT_ID,
            "query" : "FROM K8sNamespaceSample SELECT uniques(namespaceName) WHERE clusterName = '${var.cluster_name}' LIMIT MAX"
          }
        ]
      })
    }

    # Deployments in namespaces
    widget {
      title            = "Deployments in namespaces"
      row              = 1
      column           = 7
      height           = 2
      width            = 2
      visualization_id = "viz.bar"
      configuration = jsonencode({
        "nrqlQueries" : [
          {
            "accountId" : var.NEW_RELIC_ACCOUNT_ID,
            "query" : "FROM K8sDeploymentSample SELECT uniqueCount(deploymentName) WHERE clusterName = '${var.cluster_name}' FACET namespaceName LIMIT MAX"
          }
        ]
      })
    }

    # DaemonSets in namespaces
    widget {
      title            = "DaemonSets in namespaces"
      row              = 1
      column           = 9
      height           = 2
      width            = 2
      visualization_id = "viz.bar"
      configuration = jsonencode({
        "nrqlQueries" : [
          {
            "accountId" : var.NEW_RELIC_ACCOUNT_ID,
            "query" : "FROM K8sDaemonsetSample SELECT uniqueCount(daemonsetName) WHERE clusterName = '${var.cluster_name}' FACET namespaceName LIMIT MAX"
          }
        ]
      })
    }

    # StatefulSets in namespaces
    widget {
      title            = "StatefulSets in namespaces"
      row              = 1
      column           = 11
      height           = 2
      width            = 2
      visualization_id = "viz.bar"
      configuration = jsonencode({
        "nrqlQueries" : [
          {
            "accountId" : var.NEW_RELIC_ACCOUNT_ID,
            "query" : "FROM K8sStatefulsetSample SELECT uniqueCount(statefulsetName) WHERE clusterName = '${var.cluster_name}' FACET namespaceName LIMIT MAX"
          }
        ]
      })
    }

    # Pods in namespaces (Running)
    widget {
      title            = "Pods in namespaces (Running)"
      row              = 3
      column           = 1
      height           = 3
      width            = 3
      visualization_id = "viz.bar"
      configuration = jsonencode({
        "nrqlQueries" : [
          {
            "accountId" : var.NEW_RELIC_ACCOUNT_ID,
            "query" : "FROM K8sPodSample SELECT uniqueCount(podName) OR 0 AS `Running` WHERE clusterName = '${var.cluster_name}' AND status = 'Running' FACET namespace LIMIT MAX"
          }
        ]
      })
    }

    # Pods in namespaces (Pending)
    widget {
      title            = "Pods in namespaces (Pending)"
      row              = 3
      column           = 4
      height           = 3
      width            = 3
      visualization_id = "viz.bar"
      configuration = jsonencode({
        "nrqlQueries" : [
          {
            "accountId" : var.NEW_RELIC_ACCOUNT_ID,
            "query" : "FROM K8sPodSample SELECT uniqueCount(podName) OR 0 AS `Pending` WHERE clusterName = '${var.cluster_name}' AND status = 'Pending' FACET namespace LIMIT MAX"
          }
        ]
      })
    }

    # Pods in namespaces (Failed)
    widget {
      title            = "Pods in namespaces (Failed)"
      row              = 3
      column           = 7
      height           = 3
      width            = 3
      visualization_id = "viz.bar"
      configuration = jsonencode({
        "nrqlQueries" : [
          {
            "accountId" : var.NEW_RELIC_ACCOUNT_ID,
            "query" : "FROM K8sPodSample SELECT uniqueCount(podName) OR 0 AS `Failed` WHERE clusterName = '${var.cluster_name}' AND status = 'Failed' FACET namespace LIMIT MAX"
          }
        ]
      })
    }

    # Pods in namespaces (Unknown)
    widget {
      title            = "Pods in namespaces (Unknown)"
      row              = 3
      column           = 10
      height           = 3
      width            = 3
      visualization_id = "viz.bar"
      configuration = jsonencode({
        "nrqlQueries" : [
          {
            "accountId" : var.NEW_RELIC_ACCOUNT_ID,
            "query" : "FROM K8sPodSample SELECT uniqueCount(podName) OR 0 AS `Unknown` WHERE clusterName = '${var.cluster_name}' AND status = 'Unknown' FACET namespace LIMIT MAX"
          }
        ]
      })
    }

    # Top 10 CPU using namespaces (mcores)
    widget {
      title            = "Top 10 CPU using namespaces (mcores)"
      row              = 5
      column           = 1
      height           = 3
      width            = 6
      visualization_id = "viz.area"
      configuration = jsonencode({
        "nrqlQueries" : [
          {
            "accountId" : var.NEW_RELIC_ACCOUNT_ID,
            "query" : "FROM (FROM K8sContainerSample SELECT max(cpuUsedCores)*1000 AS `cpu` WHERE clusterName = '${var.cluster_name}' FACET namespaceName, podName, containerID TIMESERIES LIMIT MAX) SELECT sum(`cpu`) TIMESERIES FACET namespaceName LIMIT 10"
          }
        ]
      })
    }

    # Top 10 CPU utilizing namespaces (%)
    widget {
      title            = "Top 10 CPU utilizing namespaces (%)"
      row              = 5
      column           = 7
      width            = 6
      height           = 3
      visualization_id = "viz.line"
      configuration = jsonencode({
        "nrqlQueries" : [
          {
            "accountId" : var.NEW_RELIC_ACCOUNT_ID,
            "query" : "FROM (FROM K8sContainerSample SELECT max(cpuUsedCores) AS `usage`, max(cpuLimitCores) AS `limit` WHERE clusterName = '${var.cluster_name}' AND cpuLimitCores IS NOT NULL FACET namespaceName, podName, containerID TIMESERIES LIMIT MAX) SELECT sum(`usage`)/sum(`limit`)*100 TIMESERIES FACET namespaceName LIMIT 10"
          }
        ]
      })
    }

    # Top 10 MEM using namespaces (%)
    widget {
      title            = "Top 10 MEM using namespaces (%)"
      row              = 8
      column           = 1
      width            = 6
      height           = 3
      visualization_id = "viz.area"
      configuration = jsonencode({
        "nrqlQueries" : [
          {
            "accountId" : var.NEW_RELIC_ACCOUNT_ID,
            "query" : "FROM (FROM K8sContainerSample SELECT max(memoryUsedBytes) AS `mem` WHERE clusterName = '${var.cluster_name}' FACET namespaceName, podName, containerID TIMESERIES LIMIT MAX) SELECT sum(`mem`) TIMESERIES FACET namespaceName LIMIT 10"
          }
        ]
      })
    }

    # Top 10 MEM utilizing namespaces (%)
    widget {
      title            = "Top 10 MEM utilizing namespaces (%)"
      row              = 8
      column           = 7
      width            = 6
      height           = 3
      visualization_id = "viz.line"
      configuration = jsonencode({
        "nrqlQueries" : [
          {
            "accountId" : var.NEW_RELIC_ACCOUNT_ID,
            "query" : "FROM (FROM K8sContainerSample SELECT max(memoryUsedBytes) AS `usage`, max(memoryLimitBytes) AS `limit` WHERE clusterName = '${var.cluster_name}' AND memoryLimitBytes IS NOT NULL FACET namespaceName, podName, containerID TIMESERIES LIMIT MAX) SELECT sum(`usage`)/sum(`limit`)*100 TIMESERIES FACET namespaceName LIMIT 10"
          }
        ]
      })
    }
  }

  ####################
  ### POD OVERVIEW ###
  ####################
  page {
    name = "Pod Overview"

    # Page description
    widget {
      title            = "Page description"
      row              = 1
      column           = 1
      height           = 2
      width            = 4
      visualization_id = "viz.markdown"
      configuration = jsonencode({
        "text" : "## Pod Overview\nTo be able to visualize every widget properly, New Relic infrastructure agent should be installed."
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
            "query" : "FROM K8sContainerSample SELECT uniques(containerName) WHERE clusterName = '${var.cluster_name}' LIMIT MAX"
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
            "query" : "FROM K8sPodSample SELECT uniqueCount(podName) OR 0 AS `Running` WHERE clusterName = '${var.cluster_name}' AND status = 'Running' LIMIT MAX"
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
            "query" : "FROM K8sPodSample SELECT uniqueCount(podName) OR 0 AS `Pending` WHERE clusterName = '${var.cluster_name}' AND status = 'Pending' LIMIT MAX"
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
            "query" : "FROM K8sContainerSample SELECT uniqueCount(containerName) AS `Running` WHERE clusterName = '${var.cluster_name}' AND status = 'Running' LIMIT MAX"
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
            "query" : "FROM K8sContainerSample SELECT uniqueCount(containerName) AS `Not Running` WHERE clusterName = '${var.cluster_name}' AND status != 'Running' LIMIT MAX"
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
            "query" : "FROM K8sPodSample SELECT uniqueCount(podName) OR 0 AS `Failed` WHERE clusterName = '${var.cluster_name}' AND status = 'Failed' LIMIT MAX"
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
            "query" : "FROM K8sPodSample SELECT uniqueCount(podName) OR 0 AS `Unknown` WHERE clusterName = '${var.cluster_name}' AND status = 'Unknown' LIMIT MAX"
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
            "query": "FROM K8sPodSample SELECT filter(uniqueCount(podName), WHERE isReady = 1) / uniqueCount(podName) * 100 AS `ready (%)` WHERE clusterName = '${var.cluster_name}'"
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
            "query": "FROM K8sPodSample SELECT filter(uniqueCount(podName), WHERE isScheduled = 0) / uniqueCount(podName) * 100 AS `scheduled (%)` WHERE clusterName = '${var.cluster_name}'"
          }
        ]
      })
    }

    # Top 10 CPU using pods (mcores)
    widget {
      title            = "Top 10 CPU using pods (mcores)"
      row              = 7
      column           = 1
      height           = 3
      width            = 6
      visualization_id = "viz.area"
      configuration = jsonencode({
        "nrqlQueries" : [
          {
            "accountId" : var.NEW_RELIC_ACCOUNT_ID,
            "query" : "FROM (FROM K8sContainerSample SELECT max(cpuUsedCores)*1000 AS `cpu` WHERE clusterName = '${var.cluster_name}' FACET podName, containerID TIMESERIES LIMIT MAX) SELECT sum(`cpu`) TIMESERIES FACET podName LIMIT 10"
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
            "query" : "FROM (FROM K8sContainerSample SELECT max(cpuUsedCores) AS `usage`, max(cpuLimitCores) AS `limit` WHERE clusterName = '${var.cluster_name}' AND cpuLimitCores IS NOT NULL FACET podName, containerID TIMESERIES LIMIT MAX) SELECT sum(`usage`)/sum(`limit`)*100 TIMESERIES FACET podName LIMIT 10"
          }
        ]
      })
    }

    # Top 10 MEM using pods (bytes)
    widget {
      title            = "Top 10 MEM using pods (bytes)"
      row              = 10
      column           = 1
      width            = 6
      height           = 3
      visualization_id = "viz.area"
      configuration = jsonencode({
        "nrqlQueries" : [
          {
            "accountId" : var.NEW_RELIC_ACCOUNT_ID,
            "query" : "FROM (FROM K8sContainerSample SELECT max(memoryUsedBytes) AS `mem` WHERE clusterName = '${var.cluster_name}' FACET podName, containerID TIMESERIES LIMIT MAX) SELECT sum(`mem`) TIMESERIES FACET podName LIMIT 10"
          }
        ]
      })
    }

    # Top 10 MEM utilizing pods (%)
    widget {
      title            = "Top 10 MEM utilizing pods (%)"
      row              = 10
      column           = 7
      width            = 6
      height           = 3
      visualization_id = "viz.line"
      configuration = jsonencode({
        "nrqlQueries" : [
          {
            "accountId" : var.NEW_RELIC_ACCOUNT_ID,
            "query" : "FROM (FROM K8sContainerSample SELECT max(memoryUsedBytes) AS `usage`, max(memoryLimitBytes) AS `limit` WHERE clusterName = '${var.cluster_name}' AND memoryLimitBytes IS NOT NULL FACET podName, containerID TIMESERIES LIMIT MAX) SELECT sum(`usage`)/sum(`limit`)*100 TIMESERIES FACET podName LIMIT 10"
          }
        ]
      })
    }

    # Top 10 STO using pods (bytes)
    widget {
      title            = "Top 10 STO using pods (bytes)"
      row              = 13
      column           = 1
      width            = 6
      height           = 3
      visualization_id = "viz.area"
      configuration = jsonencode({
        "nrqlQueries" : [
          {
            "accountId" : var.NEW_RELIC_ACCOUNT_ID,
            "query" : "FROM (FROM K8sContainerSample SELECT max(fsUsedBytes) AS `sto` WHERE clusterName = '${var.cluster_name}' FACET podName, containerID TIMESERIES LIMIT MAX) SELECT sum(`sto`) TIMESERIES FACET podName LIMIT 10"
          }
        ]
      })
    }

    # Top 10 STO utilizing pods (%)
    widget {
      title            = "Top 10 STO utilizing pods (%)"
      row              = 13
      column           = 7
      width            = 6
      height           = 3
      visualization_id = "viz.line"
      configuration = jsonencode({
        "nrqlQueries" : [
          {
            "accountId" : var.NEW_RELIC_ACCOUNT_ID,
            "query" : "FROM (FROM K8sContainerSample SELECT max(fsUsedBytes) AS `usage`, max(fsCapacityBytes) AS `limit` WHERE clusterName = '${var.cluster_name}' AND fsCapacityBytes IS NOT NULL FACET podName, containerID TIMESERIES LIMIT MAX) SELECT sum(`usage`)/sum(`limit`)*100 TIMESERIES FACET podName LIMIT 10"
          }
        ]
      })
    }
  }
}
