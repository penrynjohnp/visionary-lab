// Generic Private Endpoint with DNS zone group
// Reusable for any Azure service that supports private link

@description('Location for the private endpoint')
param location string

@description('Name of the private endpoint')
param privateEndpointName string

@description('Resource ID of the subnet for the private endpoint')
param subnetId string

@description('Resource ID of the target service')
param privateLinkServiceId string

@description('Group IDs for the private link (e.g., ["blob"] for storage, ["Sql"] for Cosmos DB)')
param groupIds array

@description('Resource ID of the private DNS zone for automatic DNS registration')
param privateDnsZoneId string

resource privateEndpoint 'Microsoft.Network/privateEndpoints@2024-01-01' = {
  name: privateEndpointName
  location: location
  properties: {
    subnet: {
      id: subnetId
    }
    privateLinkServiceConnections: [
      {
        name: privateEndpointName
        properties: {
          privateLinkServiceId: privateLinkServiceId
          groupIds: groupIds
        }
      }
    ]
  }
}

resource dnsZoneGroup 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2024-01-01' = {
  parent: privateEndpoint
  name: 'default'
  properties: {
    privateDnsZoneConfigs: [
      {
        name: replace(privateEndpointName, '-', '')
        properties: {
          privateDnsZoneId: privateDnsZoneId
        }
      }
    ]
  }
}

output privateEndpointId string = privateEndpoint.id
