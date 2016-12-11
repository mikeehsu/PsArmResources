Import-Module "PsArmResources" -Force

## Global
$ResourceGroupName = "ResourceGroup11"
$Location = "usgoviowa"
$UserName = "User"
$Password = "Password"

## Storage
$StorageName = "GeneralStorage6cc"
$StorageTier = "Standard"
$StorageReplication = "GRS"

## Network
$InterfaceName = "ServerInterface06"
$Subnet1Name = "Subnet1"
$VNetName = "VNet09"
$VNetAddressPrefix = "10.0.0.0/16"
$VNetSubnetAddressPrefix = "10.0.0.0/24"

## Compute
$VMName = "VirtualMachine12"
$ComputerName = "Server22"
$VMSize = "Standard_A2"
$OSDiskName = $VMName + "OSDisk"

$TemplateFile = "$($env:TEMP)\DeployVM.json"


$Template = New-PsArmTemplate 

# Storage
$Template.resources += `
    New-PsArmStorageAccount -Name $StorageName -Location $Location -Tier $StorageTier -Replication $StorageReplication

# Network
$PublicIp = New-PsArmPublicIpAddress -Name $InterfaceName -AllocationMethod Dynamic
$Template.resources += $PublicIp

$Vnet = New-PsArmVnet -Name $VNetName -AddressPrefix $VNetAddressPrefix |
    Add-PsArmVnetSubnet -Name $Subnet1Name -AddressPrefix $VNetSubnetAddressPrefix
$Template.resources += $Vnet

$PublicIpId = Get-PsArmResourceId -Resource $PublicIp
$SubnetId = Get-PsArmVnetSubnetId -Vnet $vnet -SubnetName $Subnet1Name
$Interface = New-PsArmNetworkInterface -Name $InterfaceName -SubnetId $subnetId -PublicIpAddressId $PIp.Id
$Template.resources += $Interface

# Compute

## Setup local VM object

# $OSDiskUri = $StorageAccount.PrimaryEndpoints.Blob.ToString() + "vhds/" + $OSDiskName + ".vhd"
$InterfaceId = Get-PsArmResourceId -Resource $Interface

$Template.resources += `
    New-PsArmVMConfig -VMName $VMName -VMSize $VMSize |
        Set-PsArmVMOperatingSystem -Windows -ComputerName $ComputerName -AdminUserName $UserName -AdminPassword $Password -ProvisionVMAgent -EnableAutoUpdate |
        Set-PsArmVMSourceImage -Publisher MicrosoftWindowsServer -Offer WindowsServer -Sku 2012-R2-Datacenter -Version "latest" |
        Add-PsArmVMNetworkInterface -Id $InterfaceId |
        Set-PsArmVMOSDisk -Name $OSDiskName -CreateOption FromImage

# Resource Group

Save-PsArmTemplate -Template $Template -TemplateFile $TemplateFile

New-AzureRmResourceGroup -Name $ResourceGroupName -Location $Location
Test-AzureRmResourceGroupDeployment -ResourceGroupName $ResourceGroupName -TemplateFile $TemplateFile
New-AzureRmResourceGroupDeployment -Name $DeploymentName -ResourceGroupName $ResourceGroupName -TemplateFile $TemplateFile


