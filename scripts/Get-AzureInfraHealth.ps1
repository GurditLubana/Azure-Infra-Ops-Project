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
            Write-Host "Resource Group: $($rg.name) exists in the subscription."
            
            if($rg.location -ne "westus2") {
                Write-Host "Resource Group: $($rg.name) is not in the correct location. Expected: westus2, Actual: $($rg.location)"
                $testPass = $false
            }
            else {
                Write-Host "Resource Group: $($rg.name) is in the correct location: westus2."
            }
        }
        else {
            Write-Host "Resource Group: $($rg.name) does not exist in the subscription."
            $testPass = $false
        }

        if ($testPass) {
            Write-Host "Resource Group: $($rg.name) passed all checks.`n`n"
        }
        else {
            Write-Host "Resource Group: $($rg.name) failed one or more checks.`n`n"
        }


    }
}




function Get-AzureInfraHealth {

    ResourceGroupCheck

}


Get-AzureInfraHealth