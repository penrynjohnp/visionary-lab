@description('Location for all resources')
param location string
@description('Name of the Container App Environment')
param containerAppEnvName string
@description('Name of the Log Analytics workspace')
param logAnalyticsWorkspaceName string
@description('Whether to deploy new resources')
param deployNew bool = true
@description('Subnet ID for VNet integration (required for private Cosmos DB access)')
param subnetId string

// Subnet ID validation
var hasSubnetId = length(subnetId) > 0

// Pin to a stable API version
resource logAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2021-06-01' = {
  location: location
  name: logAnalyticsWorkspaceName
  properties: {
  }
}

// Pin to a stable API version
resource containerAppEnv 'Microsoft.App/managedEnvironments@2023-05-01' = if(deployNew) {
  name: containerAppEnvName
  location: location
  properties: {
    appLogsConfiguration: {
      destination: 'log-analytics'
      logAnalyticsConfiguration: {
        customerId: logAnalyticsWorkspace.properties.customerId
        sharedKey: logAnalyticsWorkspace.listKeys().primarySharedKey
      }
    }
    // VNet integration (only if subnet provided)
    vnetConfiguration: hasSubnetId ? {
      infrastructureSubnetId: subnetId
      internal: false
    } : null
    zoneRedundant: false
  }
}

output containerAppEnvId string = containerAppEnv.id
output containerAppDefaultDomain string = containerAppEnv.properties.defaultDomain
