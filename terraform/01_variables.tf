#################
### Variables ###
#################

### General ###

# New Relic Account ID
variable "NEW_RELIC_ACCOUNT_ID" {
  type = string
}

# New Relic API Key
variable "NEW_RELIC_API_KEY" {
  type = string
}

# New Relic Region
variable "NEW_RELIC_REGION" {
  type = string
}
######

# Cluster Name
variable "cluster_name" {
  type = string
}

# Workflow Enrichment
variable "enable_enrichments" {
  type = bool
}

# Namespace Names
variable "namespace_names" {
  type = list(string)
}

# Deployments
variable "deployments" {
  type = list(object({
    namespace_name   = string
    deployment_names = list(string)
  }))
}

# Daemonsets
variable "daemonsets" {
  type = list(object({
    namespace_name  = string
    daemonset_names = list(string)
  }))
}

# Statefulsets
variable "statefulsets" {
  type = list(object({
    namespace_name    = string
    statefulset_names = list(string)
  }))
}
