locals {

  # Alerts - List of deployments
  alerts_deployment_names = flatten(
    [
      for namespace in var.deployments : [
        for deploymentName in namespace.deploymentNames :
          deploymentName
        ]
      ]
    )
}