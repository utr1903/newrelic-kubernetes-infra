#!/bin/bash

# Get commandline arguments
while (( "$#" )); do
  case "$1" in
    --destroy)
      flagDestroy="true"
      shift
      ;;
    --dry-run)
      flagDryRun="true"
      shift
      ;;
    *)
      shift
      ;;
  esac
done

### Set variables

# Cluster name
clusterName="mydopecluster"

##################
### NAMESPACES ###
##################

# Set NerdGraph query
query='{"query":"{\n  actor {\n    nrql(accounts: '$NEWRELIC_ACCOUNT_ID', async: false, query: \"FROM K8sPodSample SELECT uniques(namespaceName) AS `namespaces` WHERE clusterName = '"'$clusterName'"' LIMIT MAX\") {\n      results\n    }\n  }\n}\n", "variables":""}'

# Clear the additional spaces
query=$(echo $query | sed 's/    /  /g')

# Query and format the namespaces
namespaces=$(curl https://api.eu.newrelic.com/graphql \
  -H "Content-Type: application/json" \
  -H "API-Key: $NEWRELIC_API_KEY" \
  --data-binary "$query" \
  | jq -r '.data.actor.nrql.results[0].namespaces' \
  | tr -d '\n' | tr -d ' ')
#########

###################
### DEPLOYMENTS ###
###################

# Set NerdGraph query
query='{"query":"{\n  actor {\n    nrql(accounts: '$NEWRELIC_ACCOUNT_ID', async: false, query: \"FROM K8sDeploymentSample SELECT uniques(deploymentName) AS `deploymentNames` WHERE clusterName = '"'$clusterName'"' FACET namespaceName LIMIT MAX\") {\n      results\n    }\n  }\n}\n", "variables":""}'

# Clear the additional spaces
query=$(echo $query | sed 's/    /  /g')

# Query and format the namespaces
deployments=$(curl https://api.eu.newrelic.com/graphql \
  -H "Content-Type: application/json" \
  -H "API-Key: $NEWRELIC_API_KEY" \
  --data-binary "$query" \
  | jq -r '.data.actor.nrql.results' \
  | tr -d '\n' | tr -d ' ')
#########

#################
### TERRAFORM ###
#################

if [[ $flagDestroy != "true" ]]; then

  # Initialise Terraform
  terraform -chdir=../terraform init

  # Plan Terraform
  terraform -chdir=../terraform plan \
    -var NEW_RELIC_ACCOUNT_ID=$NEWRELIC_ACCOUNT_ID \
    -var NEW_RELIC_API_KEY=$NEWRELIC_API_KEY \
    -var NEW_RELIC_REGION="eu" \
    -var cluster_name=$clusterName \
    -var namespace_names=$namespaces \
    -var deployments=$deployments \
    -out "./tfplan"

  # Apply Terraform
  if [[ $flagDryRun != "true" ]]; then
    terraform -chdir=../terraform apply tfplan
  fi
else

  # Destroy Terraform
  terraform -chdir=../terraform destroy \
  -var NEW_RELIC_ACCOUNT_ID=$NEWRELIC_ACCOUNT_ID \
  -var NEW_RELIC_API_KEY=$NEWRELIC_API_KEY \
  -var NEW_RELIC_REGION="eu" \
  -var cluster_name=$clusterName \
  -var namespace_names=$namespaces \
  -var deployments=$deployments
fi
#########
