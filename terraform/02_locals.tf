locals {

  ###############
  ### General ###
  ###############

  namespace_names = sort(var.namespace_names)

  ##################
  ### Dashboards ###
  ##################

  # Map of deployments
  dashboards_deployments = {
    for deployment in var.deployments : deployment.namespace_name => sort(deployment.deployment_names)
  }

  # Map of daemonsets
  dashboards_daemonsets = {
    for daemonset in var.daemonsets : daemonset.namespace_name => sort(daemonset.daemonset_names)
  }

  # Map of statefulsets
  dashboards_statefulsets = {
    for statefulset in var.statefulsets : statefulset.namespace_name => sort(statefulset.statefulset_names)
  }
  ######

  ##############
  ### Alerts ###
  ##############

  ### List of deployments

  # Stringify namespaces and deployments in order to sort them
  alerts_deployments_stringified = sort(flatten(
    [
      for namespace in var.deployments : [
        for deployment_name in sort(namespace.deployment_names) : [
          "${namespace.namespace_name},${deployment_name}"
        ]
      ]
    ]
  ))

  # Create a flattened list with each element having:
  # -> element[0] = namespace
  # -> element[1] = deployment
  alerts_deployments = [
    for value in local.alerts_deployments_stringified : flatten([
      split(",", value)
    ])
  ]
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
      (local.target_names[0]) = local.namespace_names,
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
