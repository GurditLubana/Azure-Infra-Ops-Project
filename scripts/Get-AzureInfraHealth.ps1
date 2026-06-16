# resource Groups check
# vm status
# netwrk info
# monitoring resources
# report export
$azuresession = az account show | ConvertFrom-Json
$subscriptionName = $azuresession.name
$tenant = $azuresession.tenantDisplayName
write-host "`n`nAzure Infrastructure Health Report`nProject: Azure Infra Operations Lab`nEnvironment : Dev`nSubscription: $subscriptionName`nTenant: $tenant`n`n"

function ResourceGroupCheck {

    $rgList = az group list | ConvertFrom-Json
    $requiredRGs = @(  "rg-aiol-network-dev-cc-001",  "rg-aiol-compute-dev-cc-001",  "rg-aiol-ops-dev-cc-001")


    foreach ($rg in $rgList) {

        $testPass = $true

        if ($rg.name -eq "NetworkWatcherRG") {
            continue
        }

            if ($requiredRGs -contains $rg.name) {
                Write-Host "Resource Group: $($rg.name) exists in the subscription." -ForegroundColor Green
            
            if($rg.location -ne "westus2") {
                Write-Host "Resource Group: $($rg.name) is not in the correct location. Expected: westus2, Actual: $($rg.location)" -ForegroundColor Red
                $testPass = $false
            }
            else {
                Write-Host "Resource Group: $($rg.name) is in the correct location: westus2." -ForegroundColor Green
            }
        }
        else {
            Write-Host "Resource Group: $($rg.name) does not exist in the subscription." -ForegroundColor Red
            $testPass = $false
        }

        if ($testPass) {
            Write-Host "Resource Group: $($rg.name) passed all checks.`n`n" -ForegroundColor Green
        }
        else {
            Write-Host "Resource Group: $($rg.name) failed one or more checks.`n`n" -ForegroundColor Red
        }


    }
}



function VNetCheck {

    
    $vNetList = (az network vnet list | ConvertFrom-Json)[0] # This index is because ConvertFrom-Jason returns an array. And since we only have one vnet in the subscription, we can safely access the first element of the array.

    $vNetRG = $vnetList.resourceGroup
    $vNetName = $vnetList.name
    $vNetLocation = $vnetList.location
    $vnetSubnetCount = $vnetList.subnets.length
    $vnetSubnetArray = $vnetList.subnets


    if ($vNetName -ne "vnet-aiol-dev-cc-001") {
        Write-Host "VNet is not named correctly. Expected: vnet-aiol-dev-cc-001, Actual: $vNetName" -ForegroundColor Red
    }
    else {
        Write-Host "VNet is named correctly: vnet-aiol-dev-cc-001." -ForegroundColor Green
    }

    if ($vNetRG -ne "rg-aiol-network-dev-cc-001") {
        Write-Host "VNet: $vNetName is not in the correct Resource Group. Expected: rg-aiol-network-dev-cc-001, Actual: $vNetRG" -ForegroundColor Red
    }
    else {
        Write-Host "VNet: $vNetName is in the correct Resource Group: rg-aiol-network-dev-cc-001." -ForegroundColor Green
    }

    if($vNetLocation -ne "westus2") {
        Write-Host "VNet: $vNetName is not in the correct location. Expected: westus2, Actual: $vNetLocation" -ForegroundColor Red
    }
    else {
        Write-Host "VNet: $vNetName is in the correct location: westus2." -ForegroundColor Green
    }


    $expectedSubnetArray = @{
        "snet-mgmt-dev-cc-001" = @{
            addressPrefix        = "10.20.1.0/24"
            networkSecurityGroup = "nsg-mgmt-dev-cc-001"
        }

        "snet-workload-dev-cc-001" = @{
            addressPrefix        = "10.20.2.0/24"
            networkSecurityGroup = "nsg-workload-dev-cc-001"
        }

        "snet-private-dev-cc-001" = @{
            addressPrefix        = "10.20.3.0/24"
            networkSecurityGroup = "nsg-private-dev-cc-001"
        }
    }




    $vnetSubnetArray | ForEach-Object {
        $subnetName = $_.name

        if ($expectedSubnetArray.Keys -notcontains $subnetName) {
            Write-Host "`n`n$subnetName is not expected. " -ForegroundColor Red
        }
        else {
            Write-Host "`n`n$subnetName is expected." -ForegroundColor Green

            $expectedAddressPrefix = $expectedSubnetArray[$subnetName].addressPrefix
            $expectedNSG = $expectedSubnetArray[$subnetName].networkSecurityGroup

            if ($_.addressPrefix -ne $expectedAddressPrefix) {
                Write-Host "Subnet: $subnetName does not have the correct address prefix. Expected: $expectedAddressPrefix, Actual: $($_.addressPrefix)" -ForegroundColor Red
            }
            else {
                Write-Host "Subnet: $subnetName has the correct address prefix: $expectedAddressPrefix." -ForegroundColor Green
            }

            $nsgGroupName = $_.networkSecurityGroup.id.Split("/")[-1] # This is because the NSG is returned as a resource ID, and we only need the name of the NSG for the comparison.
            if ($nsgGroupName -ne $expectedNSG) {
                Write-Host "Subnet: $subnetName is not associated with the correct NSG. Expected: $expectedNSG, Actual: $nsgGroupName" -ForegroundColor Red

            } 
            else {
                Write-Host "Subnet: $subnetName is associated with the correct NSG: $expectedNSG." -ForegroundColor Green
            }

        }

    
        if($vnetSubnetCount -ne 3) {
            Write-Host "VNet: $vNetName does not have the correct number of subnets. Expected: 3, Actual: $vnetSubnetCount" -ForegroundColor Red
        }
        else {
            Write-Host "VNet: $vNetName has the correct number of subnets: 3." -ForegroundColor Green
        }

    }

}


function NSGCheck {

    $expectedNSGs =  @{
        "nsg-mgmt-dev-cc-001" = @{
            ResourceGroup = "rg-aiol-network-dev-cc-001"
            Location      = "westus2"
            SubnetCount   = 1
        }

        "nsg-private-dev-cc-001" = @{
            ResourceGroup = "rg-aiol-network-dev-cc-001"
            Location      = "westus2"
            SubnetCount   = 1
        }

        "nsg-workload-dev-cc-001" = @{
            ResourceGroup = "rg-aiol-network-dev-cc-001"
            Location      = "westus2"
            SubnetCount   = 1
        }
    }
 


    $nsgRuleList = az network nsg list | ConvertFrom-Json
    
    $nsgRuleList | ForEach-Object {
        $nsgName = $_.name
        $rg = $_.resourceGroup
        $nsgLocation = $_.location
        $subnetCount = $_.subnets.length

        if ($expectedNSGs.Keys -notcontains $nsgName) {
            Write-Host "`n`nNSG: $nsgName is not expected." -ForegroundColor Red
        }
        else {
            Write-Host "`n`nNSG: $nsgName is expected." -ForegroundColor Green

            $expectedRG = $expectedNSGs[$nsgName].ResourceGroup
            $expectedLocation = $expectedNSGs[$nsgName].Location
            $expectedSubnetCount = $expectedNSGs[$nsgName].SubnetCount

            if ($rg -ne $expectedRG) {
                Write-Host "NSG: $nsgName is not in the correct Resource Group. Expected: $expectedRG, Actual: $rg" -ForegroundColor Red
            }
            else {
                Write-Host "NSG: $nsgName is in the correct Resource Group: $expectedRG." -ForegroundColor Green
            }

            if ($nsgLocation -ne $expectedLocation) {
                Write-Host "NSG: $nsgName is not in the correct location. Expected: $expectedLocation, Actual: $nsgLocation" -ForegroundColor Red
            }
            else {
                Write-Host "NSG: $nsgName is in the correct location: $expectedLocation." -ForegroundColor Green
            }

            if ($subnetCount -ne $expectedSubnetCount) {
                Write-Host "NSG: $nsgName does not have the correct number of subnets associated. Expected: $expectedSubnetCount, Actual: $subnetCount" -ForegroundColor Red
            }
            else {
                Write-Host "NSG: $nsgName has the correct number of subnets associated: $expectedSubnetCount." -ForegroundColor Green
            }

        }
    }

}




function Get-AzureInfraHealth {

    # ResourceGroupCheck
    # VNetCheck
    NSGCheck

}


Get-AzureInfraHealth