targetScope = 'resourceGroup'

param nsgName string
param location string
param securityRules array


resource nsg 'Microsoft.Network/networkSecurityGroups@2021-05-01' = {
  name: nsgName
  location: location
  properties: {
    securityRules: [ for securityRule in securityRules:  {
        name: securityRule.name
        properties: {
          protocol: securityRule.protocol
          sourcePortRange: securityRule.sourcePortRange
          destinationPortRange: securityRule.destinationPortRange
          sourceAddressPrefix: securityRule.sourceAddressPrefix
          destinationAddressPrefix: securityRule.destinationAddressPrefix
          access: securityRule.access
          priority: securityRule.priority
          direction: securityRule.direction
        }
      }
    ]
  }
}
