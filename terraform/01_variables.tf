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

# Namespace Names
variable "namespace_names" {
  type = list(string)
}

# Deployments
variable "deployments" {
  type = list(object({
    namespaceName = string
    deploymentNames = list(string)
  }))
}

# Daemonsets
variable "daemonsets" {
  type = list(object({
    namespaceName = string
    daemonsetNames = list(string)
  }))
}

# Statefulsets
variable "statefulsets" {
  type = list(object({
    namespaceName = string
    statefulsetNames = list(string)
  }))
}
