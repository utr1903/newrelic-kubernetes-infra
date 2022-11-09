locals {

  # Dashboards - Map of deployments
  dashboards_deployments = {
    for deployment in var.deployments : deployment.namespaceName => deployment.deploymentNames
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
