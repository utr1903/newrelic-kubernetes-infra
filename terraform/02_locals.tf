locals {

  # Alerts - List of deployments
  alerts_deployments = flatten(
    [
      for namespace in var.deployments : [
        for deploymentName in namespace.deploymentNames : {
          namespaceName = namespace.namespaceName
          deploymentName = deploymentName
        }
      ]
    ]
  )
}
