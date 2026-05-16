targetScope = 'subscription'

param resourceGroupNames array
param location string

module rgDeployment 'modules/resourceGrps.bicep' = [for rgName in resourceGroupNames: {

  //we need to give this deployment a unique name, hence name below
  name: 'deploy-${rgName}'
  params: {
    rgName: rgName
    location: location
  }

}]
