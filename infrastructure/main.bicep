targetScope = 'subscription'

param resourceGroupNames array
param vNetArray array
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
  }
}
]
