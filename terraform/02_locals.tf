locals {

  ##################
  ### Dashboards ###
  ##################

  # Map of deployments
  dashboards_deployments = {
    for deployment in var.deployments : deployment.namespaceName => deployment.deploymentNames
  }

  # Map of daemonsets
  dashboards_daemonsets = {
    for daemonset in var.daemonsets : daemonset.namespaceName => daemonset.daemonsetNames
  }

  # Map of statefulsets
  dashboards_statefulsets = {
    for statefulset in var.statefulsets : statefulset.namespaceName => statefulset.statefulsetNames
  }
  ######

  ##############
  ### Alerts ###
  ##############

  # List of deployments
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
  ######

  #################
  ### Workflows ###
  #################

  # Target names (can be teams or individuals)
  target_names = [
    "team1",
    "team2",
  ]

  # Emails
  emails = {
    (local.target_names[0]) = "team1@team.com"
    (local.target_names[1]) = "team2@team.com"
  }

  # Emails
  email_targets = {

    # Nodes
    nodes = [
      local.target_names[0]
    ]

    # Namespaces
    namespaces = {
      (local.target_names[0]) = var.namespace_names,
      (local.target_names[1]) = [
        "kube-system"
      ]
    }
  }

  # Email targets for namespaces - organized
  email_target_namespaces = flatten(
    [
      for target_name, namespace_names in local.email_targets.namespaces : [
        for namespace_name in namespace_names : {
          target_name    = target_name
          namespace_name = namespace_name
        }
      ]
    ]
  )
  ######
}
