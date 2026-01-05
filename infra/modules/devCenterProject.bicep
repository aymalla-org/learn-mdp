// Dev Center module for Managed DevOps Pool
@description('The name of the Dev Center Project')
param devCenterProjectName string

@description('The Dev Center resource ID')
param devCenterId string

@description('The location for the Dev Center Project')
param location string = resourceGroup().location

@description('Tags to apply to the Dev Center Project')
param tags object = {}


resource devCenterProject 'Microsoft.DevCenter/projects@2023-04-01' = {
  name: '${devCenterProjectName}-project'
  location: location
  tags: tags
  properties: {
    devCenterId: devCenterId
  }
}

output projectId string = devCenterProject.id
output projectName string = devCenterProject.name
