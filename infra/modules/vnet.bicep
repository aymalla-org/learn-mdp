// Virtual Network module for Managed DevOps Pool
@description('The name of the virtual network')
param vnetName string

@description('The location for the virtual network')
param location string = resourceGroup().location

@description('The address prefix for the virtual network')
param addressPrefix string = '10.0.0.0/16'

@description('The subnet name')
param subnetName string = 'snet-managed-pool'

@description('The subnet address prefix')
param subnetPrefix string = '10.0.0.0/24'

@description('Tags to apply to the virtual network')
param tags object = {}

@description('DevOps Infrastructure Service Principal Object ID')
param devOpsInfrastructureObjectId string

resource virtualNetwork 'Microsoft.Network/virtualNetworks@2023-05-01' = {
  name: vnetName
  location: location
  tags: tags
  properties: {
    addressSpace: {
      addressPrefixes: [
        addressPrefix
      ]
    }
    subnets: [
      {
        name: subnetName
        properties: {
          addressPrefix: subnetPrefix
          delegations: [
            {
              name: 'Microsoft.DevOpsInfrastructure/pools'
              properties: {
                serviceName: 'Microsoft.DevOpsInfrastructure/pools'
              }
            }
          ]
        }
      }
    ]
  }
}

// RBAC: Grant Reader and Network Contributor to the Managed Pool identity on the VNet
// These are required permissions for the "DevOpsInfrastructure" app registration objectid 3172bc25-fa41-45bd-9605-dac44334ef33
// see https://learn.microsoft.com/en-us/azure/devops/managed-devops-pools/configure-networking?view=azure-devops&tabs=azure-portal
resource vnetReaderAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(subscription().id, resourceGroup().name, vnetName, 'Reader')
  scope: virtualNetwork
  properties: {
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', 'acdd72a7-3385-48ef-bd42-f606fba81ae7') // Reader
    principalId: devOpsInfrastructureObjectId
    principalType: 'ServicePrincipal'
  }
}

resource vnetNetworkContributorAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(subscription().id, resourceGroup().name, vnetName, 'NetworkContributor')
  scope: virtualNetwork
  properties: {
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '4d97b98b-1d4f-4787-a291-c67834d212e7') // Network Contributor
    principalId: devOpsInfrastructureObjectId
    principalType: 'ServicePrincipal'
  }
}

output vnetId string = virtualNetwork.id
output subnetId string = virtualNetwork.properties.subnets[0].id
output vnetName string = virtualNetwork.name
