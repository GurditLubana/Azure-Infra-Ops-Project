// Public IP
param location string
param publicIPName string
param subnetID string
param NICname string
param linuxVMName string
param adminUsername string
param adminPublicKey string




// Public IP

resource publicIP 'Microsoft.Network/publicIPAddresses@2020-11-01' = {
  name: publicIPName
  location: location
  sku: {name: 'Standard'}
  properties: {
    publicIPAllocationMethod: 'Static'
    publicIPAddressVersion: 'IPv4'
  }
}



// NIC

resource nic 'Microsoft.Network/networkInterfaces@2020-11-01' = {
  name: NICname
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          publicIPAddress: {
            id: publicIP.id
          }
          subnet: {
            id: subnetID
          }
        }
      }
    ]
  }
}




// Linux VM

resource linuxVM 'Microsoft.Compute/virtualMachines@2020-12-01' = {
  name: linuxVMName
  location: location
  properties: {
    hardwareProfile: {
      vmSize: 'Standard_B2ats_v2'
    }
    osProfile: {
      computerName: linuxVMName
      adminUsername: adminUsername
      linuxConfiguration: {
        disablePasswordAuthentication: true
        ssh: {
          publicKeys: [
            {
              path: '/home/${adminUsername}/.ssh/authorized_keys'
              keyData: adminPublicKey
            }
          ]
        }
      }
    }
    
    storageProfile: {
      imageReference: {
        publisher: 'Canonical'
        offer: 'UbuntuServer'
        sku: '24.04-LTS'
        version: 'latest'
      }
      osDisk: {
        createOption: 'FromImage'
      }
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: nic.id
        }
      ]
    }
  }
}


