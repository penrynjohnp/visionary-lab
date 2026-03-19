// Azure Front Door Premium with private link origin to Storage blob
// Required for browser access to blobs when storage has public access disabled

@description('Name of the Front Door profile')
param frontDoorName string

@description('Hostname of the storage account blob endpoint (e.g., stxxx.blob.core.windows.net)')
param storageAccountHostName string

@description('Resource ID of the storage account')
param storageAccountId string

@description('Location of the storage account (required for private link)')
param storageAccountLocation string

resource frontDoorProfile 'Microsoft.Cdn/profiles@2024-02-01' = {
  name: frontDoorName
  location: 'global'
  sku: {
    name: 'Premium_AzureFrontDoor'
  }
  properties: {}
}

resource frontDoorEndpoint 'Microsoft.Cdn/profiles/afdEndpoints@2024-02-01' = {
  parent: frontDoorProfile
  name: '${frontDoorName}-ep'
  location: 'global'
  properties: {
    enabledState: 'Enabled'
  }
}

resource originGroup 'Microsoft.Cdn/profiles/originGroups@2024-02-01' = {
  parent: frontDoorProfile
  name: 'storage-origin-group'
  properties: {
    loadBalancingSettings: {
      sampleSize: 4
      successfulSamplesRequired: 3
    }
    healthProbeSettings: null
  }
}

resource origin 'Microsoft.Cdn/profiles/originGroups/origins@2024-02-01' = {
  parent: originGroup
  name: 'storage-blob-origin'
  properties: {
    hostName: storageAccountHostName
    originHostHeader: storageAccountHostName
    httpPort: 80
    httpsPort: 443
    priority: 1
    weight: 1000
    enforceCertificateNameCheck: true
    sharedPrivateLinkResource: {
      privateLink: {
        id: storageAccountId
      }
      groupId: 'blob'
      privateLinkLocation: storageAccountLocation
      requestMessage: 'Front Door private link to blob storage'
    }
  }
}

resource route 'Microsoft.Cdn/profiles/afdEndpoints/routes@2024-02-01' = {
  parent: frontDoorEndpoint
  name: 'storage-route'
  properties: {
    originGroup: {
      id: originGroup.id
    }
    supportedProtocols: [
      'Https'
    ]
    patternsToMatch: [
      '/*'
    ]
    forwardingProtocol: 'HttpsOnly'
    linkToDefaultDomain: 'Enabled'
    httpsRedirect: 'Enabled'
  }
  dependsOn: [
    origin
  ]
}

output frontDoorEndpointHostName string = frontDoorEndpoint.properties.hostName
output frontDoorProfileId string = frontDoorProfile.id
