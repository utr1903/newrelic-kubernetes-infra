# Kubernetes Infrastructure Monitoring

This repository is meant to provide instant observability to your Kubernetes
cluster by only running 2 scripts:
1. Installing the New Relic infrastructure agent per Helm
2. Deploying New Relic observability per Terraform

## Prerequisites

- Helm 3.x
- Terraform 0.13+

## Installation

In order to install New Relic infrastructure agent, you can run the
[01_install_infra_agent.sh](scripts/01_install_infra_agent.sh) script
with the following arguments:

| Name                      | Argument Flag            |
| ------------------------- | ------------------------ |
| deployment name           | `--deployment`           |
| deployment namespace name | `--deployment-namespace` |
| cluster name              | `--cluster`              |

- `--deployment` stands for the name of the Helm deployment (required)
- `--deployment-namespace` stands for the namespace name into which
the infra agent will be deployed (required)
- `--cluster` stands for the name of your cluster with which it will
be seen & queried within New Relic (required)

The script will add New Relic charts (https://helm-charts.newrelic.com)
to your Helm repositories and will deploy the infrastructure agent
- in priviliged mode
- in low data mode
- with `kube-state-metrics`
- with `kube-events`

**Beware**
- to define the cluster name unique since this will be
considered as one particular cluster by the prebuilt NRQL queries within the
Terraform observability scripts
- to define your New Relic license key as an environment variable
`NEWRELIC_LICENSE_KEY=xxx`

If you want to add more charts within
[newrelic-bundle](https://github.com/newrelic/helm-charts/tree/master/charts/nri-bundle),
feel free to adapt your installation script as you wish.

## Monitoring

After your installation is successful, you will see your Kubernetes
data flowing into your New Relic account. In order to have quick &
detailed overview to your cluster, you can run the
[02_deploy_newrelic_terraform.sh](scripts/02_deploy_newrelic_terraform.sh)
script with the following arguments:

| Name         | Argument Flag |
| -----------  | ------------- |
| cluster name | `--cluster`   |
| enrichment   | `--enrich`    |
| dry run      | `--dry-run`   |
| destroy      | `--destroy`   |

- `--cluster` stands for the name of your cluster with which it will
be seen & queried within New Relic (required)
- `--enrich` stands for wheather you want to enable the workflow
enrichment. Defaults to false (optional)
- `--dry-run` stands for just running `terraform plan` and prompting
what changes will look like (optional)
- `--destroy` stands for deleting the Terraform resources (optional)

**Beware**
- to set the argument `--cluster` exactly the same to the one you have
defined in your agent installation `01_install_infra_agent.sh`.
- to define your New Relic account ID as an environment variable
`NEWRELIC_ACCOUNT_ID=xxx`.
- to define the region of your New Relic account as an environment
variable `NEWRELIC_REGION="xx"`.
   - it is either `us` or `eu`
- to define your New Relic API key as an environment variable
`NEWRELIC_API_KEY=xxx`.
   - [How to create user API key](https://docs.newrelic.com/docs/apis/intro-apis/new-relic-api-keys/)

### Dashboards

Dashboards contain general information and resource consumption regarding
your nodes, namespaces and pods.

You will have 1 dashboard
- for your cluster
- for your namespaces
- for your deployments
- for your daemonsets
- for your statefulsets

This way, you will be able to have many dedicated overviews for every edge of
your cluster. You can inspect every node or namespace individually and navigate
through the dashboards from higher cluster level down to lower pod level. You
can also use of the variables within the dashboards to filter specific
Kubernetes resources (e.g. show only `deployment-a` and `deployment-b` within
namespaces `namespace-x` and `namespace-y`).

You can refer to the prebuilt queries within the dashboards and deep dive more
to get the most out of your telemetry data.

### Alerts

Alerts are currently categorized under nodes and deployments. They are set
to fire off whenever a resource utilization (CPU, memory & storage) exceeds
warning and critical levels.

In order to be able to monitor the most, it is highly recommended to set
requests & limits to your resources. Thereby you can always
be aware of the excessive consumption within your cluster.

### Workflows

Workflows are meant to notify you whenever the alert conditions are violated
and cause an issue.
Currently, only emailing is supported.
You can set the local variable `emails` in the
[02_locals.tf](terraform/02_locals.tf)
file according to which teams members you want to notify.

### Maintainers
- [Ugur Turkarslan](https://github.com/utr1903)

[![contributors](https://contributors-img.web.app/image?repo=utr1903/newrelic-kubernetes-infra)](https://github.com/utr1903/newrelic-kubernetes-infra/graphs/contributors)
