#!/bin/bash

# Get commandline arguments
while (( "$#" )); do
  case "$1" in
    --deployment)
      deployment="$2"
      shift
      ;;
    --deployment-namespace)
      deploymentNamespace="$2"
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

# New Relic license key
if [[ $NEWRELIC_LICENSE_KEY == "" ]]; then
  echo "Define New Relic license key as an environment variable [NEWRELIC_LICENSE_KEY]. For example: -> export NEWRELIC_LICENSE_KEY=xxx"
  exit 1
fi

# Deployment name
if [[ $deployment == "" ]]; then
  echo "Define deployment name with the flag [--deployment]. For example: -> newrelic-bundle"
  exit 1
fi

# Deployment namespace
if [[ $deploymentNamespace == "" ]]; then
  echo "Define deployment namespace name with the flag [--deployment-namespace]. For example -> newrelic"
  exit 1
fi

# Cluster name
if [[ $cluster == "" ]]; then
  echo "Define cluster name with the flag [--cluster]. For example -> <mydopeclusterprod>"
  exit 1
fi

# Add Helm repo
helm repo add newrelic https://helm-charts.newrelic.com

# Update Helm repo
helm repo update

# Install | upgrade
helm upgrade $deployment \
  --install \
  --wait \
  --debug \
  --set global.licenseKey=$NEWRELIC_LICENSE_KEY \
  --set global.cluster=$cluster \
  --create-namespace \
  --namespace=$deploymentNamespace \
  --set newrelic-infrastructure.privileged=true \
  --set global.lowDataMode=true \
  --set ksm.enabled=true \
  --set kubeEvents.enabled=true \
  newrelic/nri-bundle
