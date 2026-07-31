@description('Short lowercase name used in Azure resource names.')
param namePrefix string

@description('Azure region inherited from the resource group.')
param location string

@description('Linux administrator name.')
param adminUsername string

@description('Temporary SSH public key. The VM has no public IP.')
param adminSshPublicKey string

@secure()
@description('Synthetic marker value used only for a managed-identity access test.')
param labMarkerValue string

@description('Tags applied to lab resources.')
param commonTags object

var compactPrefix = toLower(replace(namePrefix, '-', ''))
var uniqueSuffix = take(uniqueString(subscription().id, resourceGroup().id), 6)
var virtualNetworkName = 'vnet-${namePrefix}-lab'
var networkSecurityGroupName = 'nsg-${namePrefix}-validation'
var validationSubnetName = 'snet-validation'
var privateEndpointSubnetName = 'snet-private-endpoints'
var managedIdentityName = 'id-${namePrefix}-workload'
var virtualMachineName = 'vm-${namePrefix}-validation'
var networkInterfaceName = 'nic-${namePrefix}-validation'
var keyVaultName = take('kv-${namePrefix}-${uniqueSuffix}', 24)
var storageAccountName = take('st${compactPrefix}${uniqueSuffix}', 24)
var logAnalyticsWorkspaceName = 'law-${namePrefix}-security'
var keyVaultPrivateDnsZoneName = 'privatelink.vaultcore.azure.net'
var blobPrivateDnsZoneName = 'privatelink.blob.${environment().suffixes.storage}'
var keyVaultSecretsUserRoleId = '4633458b-17de-408a-b874-0445c86b69e6'
var storageBlobDataReaderRoleId = '2a2b9908-6ea1-4ae2-8e65-a410df84e7d1'

resource logAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2023-09-01' = {
  name: logAnalyticsWorkspaceName
  location: location
  tags: commonTags
  properties: {
    retentionInDays: 30
    sku: {
      name: 'PerGB2018'
    }
    features: {
      enableLogAccessUsingOnlyResourcePermissions: true
    }
  }
}

resource networkSecurityGroup 'Microsoft.Network/networkSecurityGroups@2024-05-01' = {
  name: networkSecurityGroupName
  location: location
  tags: commonTags
  properties: {
    securityRules: [
      {
        name: 'Allow-Azure-Platform-HTTPS-Outbound'
        properties: {
          access: 'Allow'
          destinationAddressPrefix: 'AzureCloud'
          destinationPortRange: '443'
          direction: 'Outbound'
          priority: 100
          protocol: 'Tcp'
          sourceAddressPrefix: 'VirtualNetwork'
          sourcePortRange: '*'
        }
      }
      {
        name: 'Deny-Internet-Outbound'
        properties: {
          access: 'Deny'
          destinationAddressPrefix: 'Internet'
          destinationPortRange: '*'
          direction: 'Outbound'
          priority: 4000
          protocol: '*'
          sourceAddressPrefix: 'VirtualNetwork'
          sourcePortRange: '*'
        }
      }
    ]
  }
}

resource virtualNetwork 'Microsoft.Network/virtualNetworks@2024-05-01' = {
  name: virtualNetworkName
  location: location
  tags: commonTags
  properties: {
    addressSpace: {
      addressPrefixes: [
        '10.20.0.0/16'
      ]
    }
  }
}

resource validationSubnet 'Microsoft.Network/virtualNetworks/subnets@2024-05-01' = {
  parent: virtualNetwork
  name: validationSubnetName
  properties: {
    addressPrefix: '10.20.1.0/24'
    networkSecurityGroup: {
      id: networkSecurityGroup.id
    }
    privateEndpointNetworkPolicies: 'Enabled'
  }
}

resource privateEndpointSubnet 'Microsoft.Network/virtualNetworks/subnets@2024-05-01' = {
  parent: virtualNetwork
  name: privateEndpointSubnetName
  properties: {
    addressPrefix: '10.20.2.0/24'
    privateEndpointNetworkPolicies: 'Disabled'
  }
}

resource workloadIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' = {
  name: managedIdentityName
  location: location
  tags: commonTags
}

resource keyVault 'Microsoft.KeyVault/vaults@2024-11-01' = {
  name: keyVaultName
  location: location
  tags: commonTags
  properties: {
    tenantId: tenant().tenantId
    sku: {
      family: 'A'
      name: 'standard'
    }
    accessPolicies: []
    enableRbacAuthorization: true
    enabledForDeployment: false
    enabledForDiskEncryption: false
    enabledForTemplateDeployment: false
    enablePurgeProtection: true
    softDeleteRetentionInDays: 7
    publicNetworkAccess: 'Disabled'
    networkAcls: {
      bypass: 'None'
      defaultAction: 'Deny'
      ipRules: []
      virtualNetworkRules: []
    }
  }
}

resource labMarkerSecret 'Microsoft.KeyVault/vaults/secrets@2024-11-01' = {
  parent: keyVault
  name: 'lab-marker'
  properties: {
    value: labMarkerValue
    contentType: 'synthetic-validation-value'
    attributes: {
      enabled: true
    }
  }
}

resource keyVaultSecretReader 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(keyVault.id, workloadIdentity.id, keyVaultSecretsUserRoleId)
  scope: keyVault
  properties: {
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', keyVaultSecretsUserRoleId)
    principalId: workloadIdentity.properties.principalId
    principalType: 'ServicePrincipal'
  }
}

resource storageAccount 'Microsoft.Storage/storageAccounts@2023-05-01' = {
  name: storageAccountName
  location: location
  tags: commonTags
  kind: 'StorageV2'
  sku: {
    name: 'Standard_LRS'
  }
  properties: {
    accessTier: 'Hot'
    allowBlobPublicAccess: false
    allowCrossTenantReplication: false
    allowSharedKeyAccess: false
    defaultToOAuthAuthentication: true
    isLocalUserEnabled: false
    isNfsV3Enabled: false
    isSftpEnabled: false
    minimumTlsVersion: 'TLS1_2'
    publicNetworkAccess: 'Disabled'
    supportsHttpsTrafficOnly: true
    encryption: {
      keySource: 'Microsoft.Storage'
      requireInfrastructureEncryption: true
      services: {
        blob: {
          enabled: true
          keyType: 'Account'
        }
        file: {
          enabled: true
          keyType: 'Account'
        }
      }
    }
    networkAcls: {
      bypass: 'None'
      defaultAction: 'Deny'
      ipRules: []
      virtualNetworkRules: []
    }
  }
}

resource blobService 'Microsoft.Storage/storageAccounts/blobServices@2023-05-01' = {
  parent: storageAccount
  name: 'default'
  properties: {
    isVersioningEnabled: true
    deleteRetentionPolicy: {
      enabled: true
      days: 7
    }
    containerDeleteRetentionPolicy: {
      enabled: true
      days: 7
    }
  }
}

resource privateDataContainer 'Microsoft.Storage/storageAccounts/blobServices/containers@2023-05-01' = {
  parent: blobService
  name: 'private-data'
  properties: {
    publicAccess: 'None'
  }
}

resource storageBlobReader 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(privateDataContainer.id, workloadIdentity.id, storageBlobDataReaderRoleId)
  scope: privateDataContainer
  properties: {
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', storageBlobDataReaderRoleId)
    principalId: workloadIdentity.properties.principalId
    principalType: 'ServicePrincipal'
  }
}

resource keyVaultPrivateDnsZone 'Microsoft.Network/privateDnsZones@2024-06-01' = {
  name: keyVaultPrivateDnsZoneName
  location: 'global'
  tags: commonTags
}

resource keyVaultDnsLink 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2024-06-01' = {
  parent: keyVaultPrivateDnsZone
  name: 'link-${virtualNetworkName}'
  location: 'global'
  properties: {
    registrationEnabled: false
    virtualNetwork: {
      id: virtualNetwork.id
    }
  }
}

resource blobPrivateDnsZone 'Microsoft.Network/privateDnsZones@2024-06-01' = {
  name: blobPrivateDnsZoneName
  location: 'global'
  tags: commonTags
}

resource blobDnsLink 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2024-06-01' = {
  parent: blobPrivateDnsZone
  name: 'link-${virtualNetworkName}'
  location: 'global'
  properties: {
    registrationEnabled: false
    virtualNetwork: {
      id: virtualNetwork.id
    }
  }
}

resource keyVaultPrivateEndpoint 'Microsoft.Network/privateEndpoints@2024-05-01' = {
  name: 'pe-${keyVaultName}'
  location: location
  tags: commonTags
  properties: {
    subnet: {
      id: privateEndpointSubnet.id
    }
    privateLinkServiceConnections: [
      {
        name: 'key-vault'
        properties: {
          privateLinkServiceId: keyVault.id
          groupIds: [
            'vault'
          ]
        }
      }
    ]
  }
}

resource keyVaultPrivateDnsGroup 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2024-05-01' = {
  parent: keyVaultPrivateEndpoint
  name: 'default'
  properties: {
    privateDnsZoneConfigs: [
      {
        name: 'vault-zone'
        properties: {
          privateDnsZoneId: keyVaultPrivateDnsZone.id
        }
      }
    ]
  }
}

resource blobPrivateEndpoint 'Microsoft.Network/privateEndpoints@2024-05-01' = {
  name: 'pe-${storageAccountName}-blob'
  location: location
  tags: commonTags
  properties: {
    subnet: {
      id: privateEndpointSubnet.id
    }
    privateLinkServiceConnections: [
      {
        name: 'storage-blob'
        properties: {
          privateLinkServiceId: storageAccount.id
          groupIds: [
            'blob'
          ]
        }
      }
    ]
  }
}

resource blobPrivateDnsGroup 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2024-05-01' = {
  parent: blobPrivateEndpoint
  name: 'default'
  properties: {
    privateDnsZoneConfigs: [
      {
        name: 'blob-zone'
        properties: {
          privateDnsZoneId: blobPrivateDnsZone.id
        }
      }
    ]
  }
}

resource validationNetworkInterface 'Microsoft.Network/networkInterfaces@2024-05-01' = {
  name: networkInterfaceName
  location: location
  tags: commonTags
  properties: {
    enableAcceleratedNetworking: false
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          primary: true
          privateIPAllocationMethod: 'Dynamic'
          subnet: {
            id: validationSubnet.id
          }
        }
      }
    ]
  }
}

resource validationVirtualMachine 'Microsoft.Compute/virtualMachines@2024-07-01' = {
  name: virtualMachineName
  location: location
  tags: union(commonTags, {
    lifecycle: 'temporary-validation'
  })
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${workloadIdentity.id}': {}
    }
  }
  properties: {
    hardwareProfile: {
      vmSize: 'Standard_D2ls_v7'
    }
    osProfile: {
      computerName: virtualMachineName
      adminUsername: adminUsername
      linuxConfiguration: {
        disablePasswordAuthentication: true
        provisionVMAgent: true
        ssh: {
          publicKeys: [
            {
              path: '/home/${adminUsername}/.ssh/authorized_keys'
              keyData: adminSshPublicKey
            }
          ]
        }
      }
    }
    storageProfile: {
      imageReference: {
        publisher: 'Canonical'
        offer: '0001-com-ubuntu-server-jammy'
        sku: '22_04-lts-gen2'
        version: 'latest'
      }
      osDisk: {
        createOption: 'FromImage'
        deleteOption: 'Delete'
        managedDisk: {
          storageAccountType: 'Standard_LRS'
        }
      }
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: validationNetworkInterface.id
          properties: {
            deleteOption: 'Delete'
            primary: true
          }
        }
      ]
    }
    diagnosticsProfile: {
      bootDiagnostics: {
        enabled: true
      }
    }
    securityProfile: {
      securityType: 'TrustedLaunch'
      uefiSettings: {
        secureBootEnabled: true
        vTpmEnabled: true
      }
    }
  }
}

resource keyVaultDiagnostics 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  name: 'send-audit-to-log-analytics'
  scope: keyVault
  properties: {
    workspaceId: logAnalyticsWorkspace.id
    logAnalyticsDestinationType: 'Dedicated'
    logs: [
      {
        category: 'AuditEvent'
        enabled: true
      }
    ]
    metrics: [
      {
        category: 'AllMetrics'
        enabled: true
      }
    ]
  }
}

resource blobDiagnostics 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  name: 'send-audit-to-log-analytics'
  scope: blobService
  properties: {
    workspaceId: logAnalyticsWorkspace.id
    logAnalyticsDestinationType: 'Dedicated'
    logs: [
      {
        category: 'StorageRead'
        enabled: true
      }
      {
        category: 'StorageWrite'
        enabled: true
      }
      {
        category: 'StorageDelete'
        enabled: true
      }
    ]
    metrics: [
      {
        category: 'Transaction'
        enabled: true
      }
    ]
  }
}

output virtualMachineName string = validationVirtualMachine.name
output keyVaultName string = keyVault.name
output storageAccountName string = storageAccount.name
output managedIdentityClientId string = workloadIdentity.properties.clientId
output logAnalyticsWorkspaceName string = logAnalyticsWorkspace.name
