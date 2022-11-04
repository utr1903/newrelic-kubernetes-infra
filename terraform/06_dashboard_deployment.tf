##################
### Dashboards ###
##################

# Raw dashboard - Kubernetes Namespace Overview
resource "newrelic_one_dashboard_raw" "kubernetes_deployment_overview" {
  count = length(var.namespace_names)
  name = "K8s Cluster ${var.cluster_name} | Namespace (${var.namespace_names[count.index]}) | Deployments"

  ###########################
  ### DEPLOYMENT OVERVIEW ###
  ###########################
  dynamic "page" {
    for_each = var.deployments[index(var.deployments.*.namespaceName, var.namespace_names[count.index])].deploymentNames

    content {
      name = "${page.value}"

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
          "text": "## Deployment Overview\nNamespace -> ${var.namespace_names[count.index]}\nDeployment -> ${page.value}."
        })
      }
    }
  }
}
