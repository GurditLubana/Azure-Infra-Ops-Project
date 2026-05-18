targetScope = 'subscription'

param resourceGroupNames array
param vNetArray array
param nsgRulesArray array
param location string

module rgDeployment 'modules/resourceGrps.bicep' = [for rgName in resourceGroupNames: {

  //we need to give this deployment a unique name, hence name below
  name: 'deploy-${rgName}'
  params: {
    rgName: rgName
    location: location
  }

}]


module networkDeployment 'modules/network.bicep' = [for vNet in vNetArray: {
  name: 'deploy-${vNet.name}'
  scope: resourceGroup(vNet.rgName) // we are taking the output of the first module deployment, which is the RG name, and using it as the scope for this module deployment. This is because we want to deploy the network resources in the same RG that we just created.
  dependsOn: [rgDeployment] // we want to make sure that the RG is created before we try to deploy the network resources, hence we are adding a dependency on the RG deployment.
  params: {
    vnetName: vNet.name
    location: location
    subnetsArray: vNet.subnets
    addressSpace: vNet.addressSpace
    nsgResourceGroup: vNet.rgName // we are passing the RG name to the network module, because the NSG will be deployed in the same RG as the VNet, and we need the RG name to construct the NSG resource ID in the network module.
  }
}
]

module nsgDeployment 'modules/nsg.bicep' = [for nsg in nsgRulesArray: {
  name: 'deploy-${nsg.name}'
  scope: resourceGroup(nsg.rgName) // we are taking the output of the first module deployment, which is the RG name, and using it as the scope for this module deployment. This is because we want to deploy the NSG resources in the same RG that we just created.
  dependsOn: [rgDeployment] // we want to make sure that the RG is created before we try to deploy the NSG resources, hence we are adding a dependency on the RG deployment.
  params: {
    nsgName: nsg.name
    location: location
    securityRules: nsg.securityRules
  }
}
]


