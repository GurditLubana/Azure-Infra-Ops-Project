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
          addressPrefix: subnet.addressPrefix
          networkSecurityGroup: {id: resourceId(nsgResourceGroup, 'Microsoft.Network/networkSecurityGroups', subnet.associatedNsgName)}
        }
      }]
  }

}

output subnetIDs array = [for i in range(0, length(subnetsArray)): vnet.properties.subnets[i].id]
