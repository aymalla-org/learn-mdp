// Dev Center module for Managed DevOps Pool
@description('The name of the Dev Center')
param devCenterName string

@description('The location for the Dev Center')
param location string = resourceGroup().location

@description('Tags to apply to the Dev Center')
param tags object = {}

resource devCenter 'Microsoft.DevCenter/devcenters@2023-04-01' = {
  name: devCenterName
  location: location
  tags: tags
}

output devCenterId string = devCenter.id
output devCenterName string = devCenter.name
