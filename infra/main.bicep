targetScope = 'subscription'

param resourceGroupNames array
param vNetArray array
param nsgRulesArray array
param location string
param computeParameters object
param monitoringParameters object

module rgDeployment 'modules/resourceGrps.bicep' = [for rgName in resourceGroupNames: {

  //we need to give this deployment a unique name, hence name below
  name: 'deploy-${rgName}'
  params: {
    rgName: rgName
    location: location
  }

}]


module nsgDeployment 'modules/nsg.bicep' = [for nsg in nsgRulesArray: {
  name: 'deploy-${nsg.nsgName}'
  scope: resourceGroup(nsg.rgName) // we are taking the output of the first module deployment, which is the RG name, and using it as the scope for this module deployment. This is because we want to deploy the NSG resources in the same RG that we just created.
  dependsOn: [rgDeployment] // we want to make sure that the RG is created before we try to deploy the NSG resources, hence we are adding a dependency on the RG deployment.
  params: {
    nsgName: nsg.nsgName
    location: location
    securityRules: nsg.securityRules
  }
}
]


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


module computeDeployment 'modules/compute.bicep' = {
  name: 'deploy-compute'
  scope: resourceGroup(computeParameters.rgName)
  dependsOn: [networkDeployment] 
  params: {
    location: location
    publicIPName: computeParameters.publicIPName
    adminUsername: computeParameters.adminUsername
    adminPublicKey: computeParameters.adminPublicKey
    subnetID: networkDeployment[0].outputs.subnetIDs[1]
    NICname: computeParameters.NICname
    linuxVMName: computeParameters.linuxVMName
  }
}


module monitoringDeployment 'modules/monitoring.bicep' = {
  name: 'deploy-monitoring'
  scope: resourceGroup(monitoringParameters.rgName)
  params: {
    location: location
    targetVMid: computeDeployment.outputs.LinuxVMobject[0]
    alertName: monitoringParameters.alertName
    workspaceName: monitoringParameters.workspaceName
    actionGroupEmail: monitoringParameters.actionGroupEmail
    actionGroupName: monitoringParameters.actionGroupName
    alertMetricName: monitoringParameters.alertMetricName
    altertMetricOperator: monitoringParameters.altertMetricOperator
    altertMetricThreshold: monitoringParameters.altertMetricThreshold
    activityLogAlertName: monitoringParameters.activityLogAlertName
    nsgAlertRGname: monitoringParameters.nsgAlertRGname
  }
  }

