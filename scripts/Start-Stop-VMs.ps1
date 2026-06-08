$azureSession = az account show | ConvertFrom-Json
$subscriptionName = $azureSession.name
$owner = $azureSession.user.name
$tenant = $azureSession.tenantDisplayName
Write-Host "`n`nCurrently connected to subscription: $subscriptionName`nOwner of the Subscription: $owner`nTenant: $tenant`n`n"

$rg = "rg-aiol-compute-dev-cc-001"

Write-Host "Below are the VMs in the resource group: $rg"
$vmList = az vm list -g $rg --query "[].name" -o json | ConvertFrom-Json

foreach ($vm in $vmList) {

    #  -o tsv is required to get the output without literal quotes // which is required for the if condition to work properly.""

    $vmStatus = az vm get-instance-view -g $rg -n $vm --query "instanceView.statuses[1].displayStatus" -o tsv
    Write-Host "VM name: $vm`nVM status: $vmStatus"

    if ($vmStatus -eq "VM running"){ $action = "deallocate" } 
    else { $action = "start" }

    Write-Host "`nPerforming action: $action on VM: $vm"
    az vm $action -g $rg -n $vm

    Write-Host "$action action completed.`n`nPlease check the Updated status of the VM: $vm"

    $vmStatus = az vm get-instance-view -g $rg -n $vm --query "instanceView.statuses[1].displayStatus " -o tsv
    Write-Host "VM name: $vm`nVM status: $vmStatus`n"


    
}

