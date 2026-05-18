targetScope = 'resourceGroup'

param vnetName string
param location string
param subnetsArray array
param nsgResourceGroup string
param addressSpace string

resource vnet 'Microsoft.Network/virtualNetworks@2021-05-01' = {
  name: vnetName
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        addressSpace
      ]
    } 
    subnets: [for subnet in subnetsArray: {
        name: subnet.name
        properties: {
          addressPrefix: subnet.prefix
          networkSecurityGroup: {id: subscriptionResourceId(nsgResourceGroup, 'Microsoft.Network/networkSecurityGroups', subnet.associatedNsgName)}
        }
      }]
  }
}
