targetScope = 'subscription'

@description('Short lowercase name used in Azure resource names.')
@minLength(3)
@maxLength(12)
param namePrefix string = 'carebridge'

@description('Azure region for the lab resources.')
param location string = deployment().location

@description('Linux administrator name. The VM has no public IP and password authentication is disabled.')
param adminUsername string = 'labadmin'

@description('Temporary SSH public key used to satisfy Linux VM provisioning requirements.')
param adminSshPublicKey string

@secure()
@description('Synthetic marker value used only to verify managed-identity access to Key Vault.')
param labMarkerValue string

var resourceGroupName = 'rg-${namePrefix}-security-lab'
var commonTags = {
  environment: 'training'
  purpose: 'identity-workload-security-lab'
  dataClassification: 'synthetic'
  managedBy: 'bicep'
}

resource labResourceGroup 'Microsoft.Resources/resourceGroups@2024-03-01' = {
  name: resourceGroupName
  location: location
  tags: commonTags
}

module lab './modules/lab.bicep' = {
  name: 'deploy-${namePrefix}-security-lab'
  scope: labResourceGroup
  params: {
    namePrefix: namePrefix
    location: location
    adminUsername: adminUsername
    adminSshPublicKey: adminSshPublicKey
    labMarkerValue: labMarkerValue
    commonTags: commonTags
  }
}

output resourceGroupName string = labResourceGroup.name
output virtualMachineName string = lab.outputs.virtualMachineName
output keyVaultName string = lab.outputs.keyVaultName
output storageAccountName string = lab.outputs.storageAccountName
output managedIdentityClientId string = lab.outputs.managedIdentityClientId
output logAnalyticsWorkspaceName string = lab.outputs.logAnalyticsWorkspaceName
