
$location = 'usgovvirginia'
$ResourceGroupName = 'LiveVnet'
$lbVnetResourceGroupName = 'LiveVnet'
$lbVnetName = 'LiveVnet'
$lbSubnetName = 'SecuritySubnet'
$availabilitySetName = 'FirewallLiveVnet'

$template = New-PsArmTemplate

$template.resources += New-PsArmAvailabilitySet -Name $AvailabilitySetName -Location $location

$template.resources += New-PsArmQuickVm `
    -VmName 'Firewall' `
    -VmSize 'Standard_DS2' `
    -PlanName 'byol' `
    -Product 'barracuda-ng-firewall' `
    -Publisher 'barracudanetworks' `
    -Offer 'barracuda-ng-firewall' `
    -Sku 'byol' `
    -VNetName $lbVnetName `
    -SubnetName $lbSubnetName `
    -StaticIPAddress '192.168.2.1' `
    -AvailabilitySet $AvailabilitySetName `
    -StorageAccountResourceGroupName 'LiveVnetVA' `
    -StorageAccountName 'livevnetvastorage'

$deploymentName = $resourceGroupName + $(get-date -f yyyyMMddHHmmss)
$templateFile = $env:TEMP +'\' + $deploymentName + '.json'
Save-PsArmTemplate -Template $template -TemplateFile $templateFile

Write-Verbose "Deploying $templateFile"
New-AzureRmResourceGroup -Name $ResourceGroupName -Location USGovVirginia -Force
New-AzureRmResourceGroupDeployment -Name $deploymentName -ResourceGroupName $ResourceGroupName -TemplateFile $templateFile -Verbose
