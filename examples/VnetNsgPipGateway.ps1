Import-Module "PsArmResources" -Force

$ResourceGroupName = 'MyVnet'
$deploymentName = $resourceGroupName + $(get-date -f yyyyMMddHHmmss)
$deploymentFile = $env:TEMP + '\'+ $deploymentName + '.json'

$template = New-PsArmTemplate

$template.resources += New-PsArmNetworkSecurityGroup -Name "DefaultNsg" |
    Add-PsArmNetworkSecurityGroupRule -Name "DenyOutboundInternet"  -Priority 500 -Access 'Deny' -Direction 'Outbound' -DestinationAddressPrefix 'Internet'

$template.resources += New-PsArmVnet -Name 'MyVnet' -AddressPrefixes '10.0.0.0/21' |
    Add-PsArmVnetSubnet -Name 'GatewaySubnet' -AddressPrefix '10.0.0.0/26' |
    Add-PsArmVnetSubnet -Name 'WebSubnet'     -AddressPrefix '10.0.1.0/24' |
    Add-PsArmVnetSubnet -Name 'DataSubnet'    -AddressPrefix '10.0.2.0/23' |
    Add-PsArmVnetSubnet -Name 'AppSubnet'     -AddressPrefix '10.0.4.0/22' |
    Set-PsArmVnetNetworkSecurityGroup -NetworkSecurityGroupName 'DefaultNsg' -ApplyToAllSubnets

$template.resources += New-PsArmPublicIpAddress -Name 'GatewayPip'
$template.resources += New-PsArmVnetGateway -Name 'MyVnetGateway' -VnetName 'MyVnet' -PublicIpAddressName 'GatewayPip'

Save-PsArmTemplate -Template $template -TemplateFile $deploymentFile

New-AzureRmResourceGroup -Name $ResourceGroupName -Location 'EastUS' -Force
New-AzureRmResourceGroupDeployment -Name $deploymentName -ResourceGroupName $ResourceGroupName -TemplateFile $deploymentFile -Verbose