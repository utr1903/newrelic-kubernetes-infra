locals {

  # Dashboards - Map of deployments
  dashboards_deployments = {
    for deployment in var.deployments : deployment.namespaceName => deployment.deploymentNames
  }

  # Dashboards - Map of daemonsets
  dashboards_daemonsets = {
    for daemonset in var.daemonsets : daemonset.namespaceName => daemonset.daemonsetNames
  }

  # Dashboards - Map of statefulsets
  dashboards_statefulsets = {
    for statefulset in var.statefulsets : statefulset.namespaceName => statefulset.statefulsetNames
  }

  # Alerts - List of deployments
  alerts_deployments = flatten(
    [
      for namespace in var.deployments : [
        for deploymentName in namespace.deploymentNames : {
          namespaceName  = namespace.namespaceName
          deploymentName = deploymentName
        }
      ]
    ]
  )
}
