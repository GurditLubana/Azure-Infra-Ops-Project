// by default azure deployes in the resource group, but since we are deploying a
// resource group only, we need to set the target scope to subscription

targetScope = 'subscription'

//Below two are like a function's parameters, that are required for this file to be used. 
param rgName string
param location string

//Now we are going to actually declare the function/resource group.


resource resourceGroup 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: rgName
  location: location
}
