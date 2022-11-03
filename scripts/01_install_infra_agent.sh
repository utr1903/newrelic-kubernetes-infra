#!/bin/bash

# New Relic
declare -A newrelic
newrelic["name"]="newrelic-bundle"
newrelic["namespace"]="newrelic"
newrelic["cluster"]="mydopecluster"

# Add Helm repo
helm repo add newrelic https://helm-charts.newrelic.com

# Update Helm repo
helm repo update

# Install | upgrade
helm upgrade ${newrelic[name]} \
  --install \
  --wait \
  --debug \
  --set global.licenseKey=$NEWRELIC_LICENSE_KEY \
  --set global.cluster=${newrelic[cluster]} \
  --create-namespace \
  --namespace=${newrelic[namespace]} \
  --set newrelic-infrastructure.privileged=true \
  --set global.lowDataMode=true \
  --set ksm.enabled=true \
  --set kubeEvents.enabled=true \
  newrelic/nri-bundle
