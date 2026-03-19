// Generic Private DNS Zone with VNet link
// Reusable for any Azure private link DNS zone

@description('Name of the private DNS zone (e.g., privatelink.blob.core.windows.net)')
param zoneName string

@description('Resource ID of the VNet to link')
param vnetId string

resource privateDnsZone 'Microsoft.Network/privateDnsZones@2020-06-01' = {
  name: zoneName
  location: 'global'
  properties: {}
}

resource vnetLink 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = {
  parent: privateDnsZone
  name: '${replace(zoneName, '.', '-')}-link'
  location: 'global'
  properties: {
    virtualNetwork: {
      id: vnetId
    }
    registrationEnabled: false
  }
}

output privateDnsZoneId string = privateDnsZone.id
