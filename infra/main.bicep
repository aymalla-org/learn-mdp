// Main Bicep template for Managed DevOps Pool Infrastructure
targetScope = 'resourceGroup'

@minLength(1)
@maxLength(64)
@description('Name of the environment that can be used as part of naming resource convention')
param environmentName string

@minLength(1)
@description('Primary location for all resources')
param location string

@description('The Azure DevOps organization name')
@minLength(1)
param organizationUrl string

@description('The Azure DevOps project names')
@minLength(1)
param repositories array

@description('The virtual network address prefix')
param vnetAddressPrefix string

@description('The subnet address prefix')
param subnetAddressPrefix string

@description('The maximum number of concurrent agents')
@minValue(1)
param poolMaximumSize int

@description('The VM size for pool agents')
param vmSize string

@description('The agent image to use')
param imageName string

@description('DevOps Infrastructure Service Principal Object ID')
param devOpsInfrastructureObjectId string

var deploymentUniqueId = toLower(uniqueString(subscription().id, environmentName, location))

var tags = {
  'azd-env-name': environmentName
  environment: environmentName
  managedBy: 'Bicep'
  purpose: 'ManagedDevOpsPool'
  deploymentUniqueId: deploymentUniqueId
}

// Deploy Virtual Network
module vnet 'modules/vnet.bicep' = {
  name: 'vnet-deployment'
  params: {
    vnetName: 'mdp-vnet-${deploymentUniqueId}'
    subnetName: 'mdp-snet-${deploymentUniqueId}'
    location: location
    addressPrefix: vnetAddressPrefix
    subnetPrefix: subnetAddressPrefix
    tags: tags
    devOpsInfrastructureObjectId: devOpsInfrastructureObjectId
  }
}

// Deploy Dev Center
module devCenter 'modules/devCenter.bicep' = {
  name: 'devcenter-deployment'
  params: {
    devCenterName: 'mdp-dc-${deploymentUniqueId}'
    location: location
    tags: tags
  }
}

// Deploy Managed DevOps Pool
module managedPool 'modules/managedPool.bicep' = {
  name: 'managedpool-deployment'
  params: {
    poolName: 'mdp-pool-${deploymentUniqueId}'
    location: location
    devCenterProjectResourceId: devCenter.outputs.projectId
    subnetId: vnet.outputs.subnetId
    organizationUrl: organizationUrl
    repositories: repositories
    maximumConcurrency: poolMaximumSize
    vmSize: vmSize
    imageName: imageName
    tags: tags
  }
}

// Outputs
output DEVCENTER_ID string = devCenter.outputs.devCenterId
output DEVCENTER_NAME string = devCenter.outputs.devCenterName
output DEVCENTER_PROJECT_ID string = devCenter.outputs.projectId
output DEVCENTER_PROJECT_NAME string = devCenter.outputs.projectName
output VNET_ID string = vnet.outputs.vnetId
output VNET_NAME string = vnet.outputs.vnetName
output SUBNET_ID string = vnet.outputs.subnetId
output MDP_POOL_ID string = managedPool.outputs.poolId
output MDP_POOL_NAME string = managedPool.outputs.poolName
