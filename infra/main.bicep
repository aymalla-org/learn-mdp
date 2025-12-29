// Main Bicep template for Managed DevOps Pool Infrastructure
targetScope = 'resourceGroup'

@minLength(1)
@maxLength(64)
@description('Name of the environment that can be used as part of naming resource convention')
param environmentName string

@minLength(1)
@description('Primary location for all resources')
param location string

@description('The name of the Dev Center')
param devCenterName string = '${environmentName}-mdp-devcenter'

@description('The name of the Virtual Network')
param vnetName string = '${environmentName}-mdp-vnet'

@description('The name of the Managed DevOps Pool')
param poolName string = '${environmentName}-mdp-pool'

@description('The Azure DevOps organization name')
@minLength(1)
param organizationUrl string

@description('The Azure DevOps project names')
@minLength(1)
param repositories array

@description('The virtual network address prefix')
param vnetAddressPrefix string = '10.0.0.0/16'

@description('The subnet name')
param subnetName string = 'snet-managed-pool'

@description('The subnet address prefix')
param subnetAddressPrefix string = '10.0.0.0/24'

@description('The maximum number of concurrent agents')
@minValue(1)
param maximumConcurrency int = 1

@description('The VM size for pool agents')
param vmSize string = 'Standard_D4ads_v5'

@description('The agent image to use')
param imageName string = 'ubuntu-latest'

@description('DevOps Infrastructure Service Principal Object ID')
param devOpsInfrastructureObjectId string

var tags = {
  'azd-env-name': environmentName
  environment: environmentName
  managedBy: 'Bicep'
  purpose: 'ManagedDevOpsPool'
}

// Deploy Virtual Network
module vnet 'modules/vnet.bicep' = {
  name: 'vnet-deployment'
  params: {
    vnetName: vnetName
    subnetName: subnetName
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
    devCenterName: devCenterName
    location: location
    tags: tags
  }
}

// Deploy Managed DevOps Pool
module managedPool 'modules/managedPool.bicep' = {
  name: 'managedpool-deployment'
  params: {
    poolName: poolName
    location: location
    devCenterProjectResourceId: devCenter.outputs.projectId
    subnetId: vnet.outputs.subnetId
    organizationUrl: organizationUrl
    repositories: repositories
    maximumConcurrency: maximumConcurrency
    vmSize: vmSize
    imageName: imageName
    tags: tags
  }
}

// Outputs
output devCenterId string = devCenter.outputs.devCenterId
output devCenterName string = devCenter.outputs.devCenterName
output devCenterProjectId string = devCenter.outputs.projectId
output devCenterProjectName string = devCenter.outputs.projectName
output vnetId string = vnet.outputs.vnetId
output vnetName string = vnet.outputs.vnetName
output subnetId string = vnet.outputs.subnetId
output poolId string = managedPool.outputs.poolId
output poolName string = managedPool.outputs.poolName
