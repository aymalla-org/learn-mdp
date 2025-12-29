// Managed DevOps Pool module
@description('The name of the Managed DevOps Pool')
param poolName string

@description('The location for the Managed DevOps Pool')
param location string = resourceGroup().location

@description('The Dev Center Project resource ID')
param devCenterProjectResourceId string

@description('The subnet resource ID for the pool')
param subnetId string

@description('The maximum number of agents in the pool')
@minValue(1)
param maximumConcurrency int = 10

@description('The Azure DevOps organization URL')
@minLength(1)
param organizationUrl string = 'https://github.com/orgs/aymalla-org'

@description('The Azure DevOps project names. When left empty (default), the pool is available to all projects in the organization.')
param repositories array = ['learn-mdp']

@description('The agent image to use')
param imageName string = 'ubuntu-24.04'

@description('The VM size for the agents')
param vmSize string = 'Standard_D2s_v3'

@description('Tags to apply to the Managed DevOps Pool')
param tags object = {}

@description('Resource predictions configuration for the pool agents (optional)')
param resourcePredictions object?

@description('Resource predictions profile for the pool agents (optional)')
param resourcePredictionsProfile object?

resource managedPool 'Microsoft.DevOpsInfrastructure/pools@2024-04-04-preview' = {
  name: poolName
  location: location
  tags: tags
  properties: {
    devCenterProjectResourceId: devCenterProjectResourceId
    maximumConcurrency: maximumConcurrency
    organizationProfile: {
      kind: 'GitHub'
      organizations: [
        {
          url: organizationUrl
          repositories: repositories
        }
      ]
    }
    agentProfile: {
      maxAgentLifetime: '0.08:00:00'
      gracePeriodTimeSpan: '0.00:05:00'
      kind: 'Stateful'
      resourcePredictionsProfile: resourcePredictionsProfile
      resourcePredictions: resourcePredictions
    }
    fabricProfile: {
      kind: 'Vmss'
      sku: {
        name: vmSize
      }
      images: [
        {
          wellKnownImageName: imageName
        }
      ]
      networkProfile: {
        subnetId: subnetId
      }
    }
  }
}

output poolId string = managedPool.id
output poolName string = managedPool.name
