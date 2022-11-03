##################
### Dashboards ###
##################

# Raw dashboard - Kubernetes Bundle
resource "newrelic_one_dashboard_raw" "kubernetes_bundle" {
  name = "Kubernetes Monitoring with Bundle"

  #####################
  ### NODE OVERVIEW ###
  #####################
  page {
    name = "Node Overview"

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
        "text": "## Node Overview\nTo be able to visualize every widget properly, New Relic infrastructure agent should be installed."
      })
    }

    # Node Capacities
    widget {
      title  = "Node Capacities"
      row    = 2
      column = 1
      height = 3
      width  = 4
      visualization_id = "viz.table"
      configuration = jsonencode(
      {
        "nrqlQueries": [
          {
            "accountId": var.NEW_RELIC_ACCOUNT_ID,
            "query": "FROM Metric SELECT latest(k8s.node.capacityCpuCores) AS 'CPU (cores)', latest(k8s.node.capacityMemoryBytes)/1024/1024/1024 AS 'MEM (GiB)' WHERE clusterName = '${var.cluster_name}' FACET k8s.nodeName"
          }
        ]
      })
    }

    # Node to Pod Map
    widget {
      title  = "Node to Pod Map"
      row    = 1
      column = 5
      height = 5
      width  = 4
      visualization_id = "viz.table"
      configuration = jsonencode(
      {
        "nrqlQueries": [
          {
            "accountId": var.NEW_RELIC_ACCOUNT_ID,
            "query": "FROM K8sPodSample SELECT uniques(concat(nodeName, ' -> ', podName)) AS `Node -> Pod` WHERE clusterName = '${var.cluster_name}'"
          }
        ]
      })
    }

    # Num Namespaces by Nodes
    widget {
      title  = "Num Namespaces by Nodes"
      row    = 1
      column = 9
      height = 2
      width  = 4
      visualization_id = "viz.line"
      configuration = jsonencode(
      {
        "nrqlQueries": [
          {
            "accountId": var.NEW_RELIC_ACCOUNT_ID,
            "query": "FROM K8sPodSample SELECT uniqueCount(namespaceName) WHERE clusterName = '${var.cluster_name}' FACET nodeName TIMESERIES LIMIT MAX"
          }
        ]
      })
    }

    # Num Pods by Nodes
    widget {
      title  = "Num Pods by Nodes"
      row    = 2
      column = 9
      height = 3
      width  = 4
      visualization_id = "viz.line"
      configuration = jsonencode(
      {
        "nrqlQueries": [
          {
            "accountId": var.NEW_RELIC_ACCOUNT_ID,
            "query": "FROM K8sPodSample SELECT uniqueCount(podName) WHERE clusterName = '${var.cluster_name}' FACET nodeName TIMESERIES LIMIT MAX"
          }
        ]
      })
    }

    # Node CPU Usage (mcores)
    widget {
      title  = "Node CPU Usage (mcores)"
      row    = 3
      column = 1
      width  = 6
      visualization_id = "viz.area"
      configuration = jsonencode(
      {
        "nrqlQueries": [
          {
            "accountId": var.NEW_RELIC_ACCOUNT_ID,
            "query": "FROM Metric SELECT average(k8s.node.cpuUsedCores)*1000 AS `CPU (mcores)` WHERE clusterName = '${var.cluster_name}' FACET k8s.nodeName TIMESERIES LIMIT MAX"
          }
        ]
      })
    }

    # Node CPU Utilization (%)
    widget {
      title  = "Node CPU Utilization (%)"
      row    = 3
      column = 7
      width  = 6
      visualization_id = "viz.line"
      configuration = jsonencode(
      {
        "nrqlQueries": [
          {
            "accountId": var.NEW_RELIC_ACCOUNT_ID,
            "query": "FROM Metric SELECT average(k8s.node.cpuUsedCores)/max(k8s.node.capacityCpuCores)*100 WHERE clusterName = '${var.cluster_name}' FACET k8s.nodeName TIMESERIES LIMIT MAX"
          }
        ]
      })
    }

    # Node MEM Usage (bytes)
    widget {
      title  = "Node MEM Usage (bytes)"
      row    = 4
      column = 1
      width  = 6
      visualization_id = "viz.area"
      configuration = jsonencode(
      {
        "nrqlQueries": [
          {
            "accountId": var.NEW_RELIC_ACCOUNT_ID,
            "query": "FROM Metric SELECT average(k8s.node.memoryUsedBytes) AS `MEM (bytes)` WHERE clusterName = '${var.cluster_name}' FACET k8s.nodeName TIMESERIES LIMIT MAX"
          }
        ]
      })
    }

    # Node MEM Utilization (%)
    widget {
      title  = "Node MEM Utilization (%)"
      row    = 4
      column = 7
      width  = 6
      visualization_id = "viz.line"
      configuration = jsonencode(
      {
        "nrqlQueries": [
          {
            "accountId": var.NEW_RELIC_ACCOUNT_ID,
            "query": "FROM Metric SELECT average(k8s.node.memoryUsedBytes)/max(k8s.node.capacityMemoryBytes)*100 WHERE clusterName = '${var.cluster_name}' FACET k8s.nodeName TIMESERIES LIMIT MAX"
          }
        ]
      })
    }

    # Node STO Usage (bytes)
    widget {
      title  = "Node STO Usage (bytes)"
      row    = 5
      column = 1
      width  = 6
      visualization_id = "viz.area"
      configuration = jsonencode(
      {
        "nrqlQueries": [
          {
            "accountId": var.NEW_RELIC_ACCOUNT_ID,
            "query": "FROM Metric SELECT average(k8s.node.fsUsedBytes) AS `STO (bytes)` WHERE clusterName = '${var.cluster_name}' FACET k8s.nodeName TIMESERIES LIMIT MAX"
          }
        ]
      })
    }

    # Node STO Utilization (%)
    widget {
      title  = "Node STO Utilization (%)"
      row    = 5
      column = 7
      width  = 6
      visualization_id = "viz.line"
      configuration = jsonencode(
      {
        "nrqlQueries": [
          {
            "accountId": var.NEW_RELIC_ACCOUNT_ID,
            "query": "FROM Metric SELECT average(k8s.node.fsUsedBytes)/max(k8s.node.fsCapacityBytes)*100 WHERE clusterName = '${var.cluster_name}' FACET k8s.nodeName TIMESERIES LIMIT MAX"
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
        "text": "## Namespace Overview\nTo be able to visualize every widget properly, New Relic infrastructure agent should be installed."
      })
    }

    # Namespaces
    widget {
      title  = "Namespaces"
      row    = 1
      column = 5
      height = 2
      width  = 2
      visualization_id = "viz.table"
      configuration = jsonencode(
      {
        "nrqlQueries": [
          {
            "accountId": var.NEW_RELIC_ACCOUNT_ID,
            "query": "FROM K8sNamespaceSample SELECT uniques(namespaceName) WHERE clusterName = '${var.cluster_name}' LIMIT MAX"
          }
        ]
      })
    }

    # Deployments in Namespaces
    widget {
      title  = "Deployments in Namespaces"
      row    = 1
      column = 7
      height = 2
      width  = 2
      visualization_id = "viz.bar"
      configuration = jsonencode(
      {
        "nrqlQueries": [
          {
            "accountId": var.NEW_RELIC_ACCOUNT_ID,
            "query": "FROM K8sDeploymentSample SELECT uniqueCount(deploymentName) WHERE clusterName = '${var.cluster_name}' FACET namespaceName LIMIT MAX"
          }
        ]
      })
    }

    # DaemonSets in Namespaces
    widget {
      title  = "DaemonSets in Namespaces"
      row    = 1
      column = 9
      height = 2
      width  = 2
      visualization_id = "viz.bar"
      configuration = jsonencode(
      {
        "nrqlQueries": [
          {
            "accountId": var.NEW_RELIC_ACCOUNT_ID,
            "query": "FROM K8sDaemonsetSample SELECT uniqueCount(daemonsetName) WHERE clusterName = '${var.cluster_name}' FACET namespaceName LIMIT MAX"
          }
        ]
      })
    }

    # StatefulSets in Namespaces
    widget {
      title  = "StatefulSets in Namespaces"
      row    = 1
      column = 11
      height = 2
      width  = 2
      visualization_id = "viz.bar"
      configuration = jsonencode(
      {
        "nrqlQueries": [
          {
            "accountId": var.NEW_RELIC_ACCOUNT_ID,
            "query": "FROM K8sStatefulsetSample SELECT uniqueCount(statefulsetName) WHERE clusterName = '${var.cluster_name}' FACET namespaceName LIMIT MAX"
          }
        ]
      })
    }

    # Pods in Namespaces (Running)
    widget {
      title  = "Pods in Namespaces (Running)"
      row    = 3
      column = 1
      height = 3
      width  = 3
      visualization_id = "viz.bar"
      configuration = jsonencode(
      {
        "nrqlQueries": [
          {
            "accountId": var.NEW_RELIC_ACCOUNT_ID,
            "query": "FROM K8sPodSample SELECT uniqueCount(podName) OR 0 WHERE clusterName = '${var.cluster_name}' AND status = 'Running' FACET namespace LIMIT MAX"
          }
        ]
      })
    }

    # Pods in Namespaces (Pending)
    widget {
      title  = "Pods in Namespaces (Pending)"
      row    = 3
      column = 4
      height = 3
      width  = 3
      visualization_id = "viz.bar"
      configuration = jsonencode(
      {
        "nrqlQueries": [
          {
            "accountId": var.NEW_RELIC_ACCOUNT_ID,
            "query": "FROM K8sPodSample SELECT uniqueCount(podName) OR 0 WHERE clusterName = '${var.cluster_name}' AND status = 'Pending' FACET namespace LIMIT MAX"
          }
        ]
      })
    }

    # Pods in Namespaces (Failed)
    widget {
      title  = "Pods in Namespaces (Failed)"
      row    = 3
      column = 7
      height = 3
      width  = 3
      visualization_id = "viz.bar"
      configuration = jsonencode(
      {
        "nrqlQueries": [
          {
            "accountId": var.NEW_RELIC_ACCOUNT_ID,
            "query": "FROM K8sPodSample SELECT uniqueCount(podName) OR 0 WHERE clusterName = '${var.cluster_name}' AND status = 'Failed' FACET namespace LIMIT MAX"
          }
        ]
      })
    }

    # Pods in Namespaces (Unknown)
    widget {
      title  = "Pods in Namespaces (Unknown)"
      row    = 3
      column = 10
      height = 3
      width  = 3
      visualization_id = "viz.bar"
      configuration = jsonencode(
      {
        "nrqlQueries": [
          {
            "accountId": var.NEW_RELIC_ACCOUNT_ID,
            "query": "FROM K8sPodSample SELECT uniqueCount(podName) OR 0 WHERE clusterName = '${var.cluster_name}' AND status = 'Unknown' FACET namespace LIMIT MAX"
          }
        ]
      })
    }

    # Container CPU Usage per Namespace (mcores)
    widget {
      title  = "Container CPU Usage per Namespace (mcores)"
      row    = 5
      column = 1
      width  = 6
      visualization_id = "viz.area"
      configuration = jsonencode(
      {
        "nrqlQueries": [
          {
            "accountId": var.NEW_RELIC_ACCOUNT_ID,
            "query": "FROM (FROM Metric SELECT average(k8s.container.cpuUsedCores) AS `cpu` WHERE k8s.clusterName = '${var.cluster_name}' FACET k8s.namespaceName, k8s.podName TIMESERIES LIMIT MAX) SELECT sum(cpu) FACET namespaceName TIMESERIES LIMIT MAX"
          }
        ]
      })
    }

    # Container CPU Utilization per Namespace (%)
    widget {
      title  = "Container CPU Utilization per Namespace (%)"
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
            "query": "FROM (FROM Metric SELECT average(k8s.container.cpuUsedCores) AS `usage`, average(k8s.container.cpuLimitCores) AS `limit` WHERE k8s.containerName IN (FROM Metric SELECT uniques(k8s.containerName) WHERE k8s.clusterName = '${var.cluster_name}' AND k8s.container.cpuLimitCores IS NOT NULL LIMIT MAX) FACET k8s.namespaceName, k8s.podName TIMESERIES LIMIT MAX) SELECT sum(`usage`)/sum(`limit`)*100 FACET namespaceName TIMESERIES LIMIT MAX"
          }
        ]
      })
    }

    # Container MEM Usage per Namespace (bytes)
    widget {
      title  = "Container MEM Usage per Namespace (bytes)"
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
            "query": "FROM (FROM Metric SELECT average(k8s.container.memoryUsedBytes) AS `mem` WHERE k8s.clusterName = '${var.cluster_name}' FACET k8s.namespaceName, k8s.podName TIMESERIES LIMIT MAX) SELECT sum(mem) FACET namespaceName TIMESERIES LIMIT MAX"
          }
        ]
      })
    }

    # Container MEM Utilization per Namespace (%)
    widget {
      title  = "Container MEM Utilization per Namespace (%)"
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
            "query": "FROM (FROM Metric SELECT average(k8s.container.memoryUsedBytes) AS `usage`, average(k8s.container.memoryLimitBytes) AS `limit` WHERE k8s.containerName IN (FROM Metric SELECT uniques(k8s.containerName) WHERE k8s.clusterName = '${var.cluster_name}' AND k8s.container.memoryLimitBytes IS NOT NULL LIMIT MAX) FACET k8s.namespaceName, k8s.podName TIMESERIES LIMIT MAX) SELECT sum(`usage`)/sum(`limit`)*100 FACET namespaceName TIMESERIES LIMIT MAX"
          }
        ]
      })
    }
  }
}
