# MDP - Azure Managed DevOps Pools Agents Stuck Case Replication

This repository contains infrastructure as code (IaC) to deploy an Azure Managed DevOps Pools (MDP) environment and integrate a GitHub repository’s Actions to use it. The setup replicates the issue of self-hosted runners getting stuck in the “Allocated” state and is intended for troubleshooting and testing purposes.

Based on my investigation, the issue appears to be caused by high concurrency levels in MDP, specifically related to resource allocation and disposal.

### Prerequisites

- An Azure subscription
- Azure Managed DevOps Pools subscription prerequisites (see [Azure Managed DevOps Pools documentation](https://learn.microsoft.com/en-us/azure/devops/managed-devops-pools/prerequisites?view=azure-devops&tabs=azure-portal))
- GitHub organization with `Managed DevOps Pools application` installed
- Fork of this repository in your GitHub organization

#### Tools

- Azure Developer CLI (azd)
- GitHub CLI (gh)
- DevContainer (Has all necessary tools pre-installed)

## Getting Started

### Clone the Repository

```bash
git clone https://github.com/<your-org>/<your-repo>.git
cd <your-repo>
```

### Initialize DevContainer

Open the repository in a DevContainer to ensure all required tools are available.

### Infrastructure Deployment

The infrastructure setup includes:

- **Dev Center**: Azure Dev Center for managing development infrastructure
- **Dev Center Project**: Project configuration within the Dev Center
- **Virtual Network**: Dedicated VNet with subnet delegation for managed pools
- **Managed DevOps Pool**: Scalable pool of build agents for CI/CD pipelines

```bash

# Azue Login
az login

# Initialize azd (first time only)
azd init

# Set required environment variables
azd env set AZURE_LOCATION "swedencentral"

azd env set AZURE_ENV_NAME "<unique-env-name>"
azd env set GITHUB_ORG_URL "<your-org-url>"
azd env set GITHUB_REPOSITORY_NAME "<your-repo-name>"

principal_id=$(az ad sp list --display-name 'DevOpsInfrastructure' --query '[0].id' -o tsv)
azd env set DEVOPSINFRASTRUCTURE_PRINCIPLE_ID "$principal_id"

# Provision and deploy infrastructure
azd up
```

### Trigger the GitHub Workflows

```bash

gh auth login

# Trigger two batches of MDP test workflows in parallel (each batch triggers 100 workflows runs)
make trigger-workflow-batch & make trigger-workflow-batch

```

> After each batch completes, check the workflow runs in your GitHub repository to observe the behavior of the MDP agents. you should see some agents getting stuck in the "Allocated" state.

## Deployment Customization

Change the parameters in `main.parameters.json` to specify the desired Azure region for deployment, Image, and VM size.

- **Supported Azure Regions:** Available regions for resource type 'Microsoft.DevCenter/devcenters': [`australiaeast`, `brazilsouth`, `canadacentral`, `centralus`, `francecentral`, `polandcentral`, `spaincentral`, `uaenorth`, `westeurope`, `germanywestcentral`, `italynorth`, `japaneast`, `japanwest`, `uksouth`, `eastus`, `eastus2`, `southafricanorth`, `southcentralus`, `southeastasia`, `switzerlandnorth`, `swedencentral`, `westus2`, `westus3`, `centralindia`, `eastasia`, `northeurope`, `koreacentral`], default is `swedencentral`.
- **Supported images:** [`windows-2019`, `windows-2022`, `windows-2025`, `ubuntu-20.04`, `ubuntu-22.04`, `ubuntu-24.04`], default is `ubuntu-24.04`.
- **VM Size:** based on the availabe quota in your subscription for MDP (the default is `Standard_D4ads_v5`).
- **Network Configuration**: To use a custom VNet address space, modify these parameters: `vnetAddressPrefix`: Virtual network CIDR (default: 10.0.0.0/16), `subnetAddressPrefix`: Subnet CIDR (default: 10.0.0.0/24)

## Documentation

- [Azure Managed DevOps Pools](https://learn.microsoft.com/en-us/azure/devops/managed-devops-pools/overview?view=azure-devops)
- [Azure MDP Deployment using Bicep Modules](https://github.com/Azure/bicep-registry-modules/tree/main/avm/res/dev-ops-infrastructure/pool)
- Azure Portal link to access the in-preview features of Azure MDP (GitHub integration): [Azure Portal MDP](https://aka.ms/mdp-github)

## License

See [LICENSE](./LICENSE) file for details.
