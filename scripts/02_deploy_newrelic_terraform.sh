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
    --cluster)
      cluster="$2"
      shift
      ;;
    *)
      shift
      ;;
  esac
done

### Check input

# New Relic account ID
if [[ $NEWRELIC_ACCOUNT_ID == "" ]]; then
  echo "Define New Relic account ID as an environment variable [NEWRELIC_ACCOUNT_ID]. For example: -> export NEWRELIC_ACCOUNT_ID=xxx"
  exit 1
fi

# New Relic region
if [[ $NEWRELIC_REGION == "" ]]; then
  echo "Define New Relic region as an environment variable [NEWRELIC_REGION]. For example: -> export NEWRELIC_REGION=us or export NEWRELIC_REGION=eu"
  exit 1
else
  if [[ $NEWRELIC_REGION != "us" && $NEWRELIC_REGION != "eu" ]]; then
    echo "New Relic region can either be 'us' or 'eu'."
    exit 1
  fi
fi

# New Relic API key
if [[ $NEWRELIC_API_KEY == "" ]]; then
  echo "Define New Relic API key as an environment variable [NEWRELIC_API_KEY]. For example: -> export NEWRELIC_API_KEY=xxx"
  exit 1
fi

# Cluster name
if [[ $cluster == "" ]]; then
  echo "Define cluster name with the flag [--cluster]. For example -> <mydopeclusterprod>"
  exit 1
fi

##################
### NAMESPACES ###
##################

# Set NerdGraph query
query='{"query":"{\n  actor {\n    nrql(accounts: '$NEWRELIC_ACCOUNT_ID', async: false, query: \"FROM K8sPodSample SELECT uniques(namespaceName) AS `namespaces` WHERE clusterName = '"'$cluster'"' LIMIT MAX\") {\n      results\n    }\n  }\n}\n", "variables":""}'

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
query='{"query":"{\n  actor {\n    nrql(accounts: '$NEWRELIC_ACCOUNT_ID', async: false, query: \"FROM K8sDeploymentSample SELECT uniques(deploymentName) AS `deployment_names` WHERE clusterName = '"'$cluster'"' FACET namespaceName AS `namespace_name` LIMIT MAX\") {\n      results\n    }\n  }\n}\n", "variables":""}'

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

##################
### DAEMONSETS ###
##################

# Set NerdGraph query
query='{"query":"{\n  actor {\n    nrql(accounts: '$NEWRELIC_ACCOUNT_ID', async: false, query: \"FROM K8sDaemonsetSample SELECT uniques(daemonsetName) AS `daemonset_names` WHERE clusterName = '"'$cluster'"' FACET namespaceName AS `namespace_name` LIMIT MAX\") {\n      results\n    }\n  }\n}\n", "variables":""}'

# Clear the additional spaces
query=$(echo $query | sed 's/    /  /g')

# Query and format the namespaces
daemonsets=$(curl https://api.eu.newrelic.com/graphql \
  -H "Content-Type: application/json" \
  -H "API-Key: $NEWRELIC_API_KEY" \
  --data-binary "$query" \
  | jq -r '.data.actor.nrql.results' \
  | tr -d '\n' | tr -d ' ')
#########

####################
### STATEFULSETS ###
####################

# Set NerdGraph query
query='{"query":"{\n  actor {\n    nrql(accounts: '$NEWRELIC_ACCOUNT_ID', async: false, query: \"FROM K8sStatefulsetSample SELECT uniques(statefulsetName) AS `statefulset_names` WHERE clusterName = '"'$cluster'"' FACET namespaceName AS `namespace_name` LIMIT MAX\") {\n      results\n    }\n  }\n}\n", "variables":""}'

# Clear the additional spaces
query=$(echo $query | sed 's/    /  /g')

# Query and format the namespaces
statefulsets=$(curl https://api.eu.newrelic.com/graphql \
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
    -var cluster_name=$cluster \
    -var namespace_names=$namespaces \
    -var deployments=$deployments \
    -var daemonsets=$daemonsets \
    -var statefulsets=$statefulsets \
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
  -var cluster_name=$cluster \
  -var namespace_names=$namespaces \
  -var deployments=$deployments \
  -var daemonsets=$daemonsets \
  -var statefulsets=$statefulsets
fi
#########
