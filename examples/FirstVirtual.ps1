<# 
This is the PsArmResource equivalent to the tutorial,
"Create your first virtual network" at
https://docs.microsoft.com/en-us/azure/virtual-network/virtual-network-get-started-vnet-subnet
#>

param( 
 [switch] $RunIt,
 [string] $Path
)
Import-Module "PsArmResources" -Force
Set-StrictMode -Version latest
$ErrorActionPreference = "Stop"

$location = "EastUS"
# Initialize the Template
$template = New-PsArmTemplate

# Add the Vnet, with Subnets:
$vNet =  New-PsArmVnet -Name 'MyVNet' -AddressPrefixes '10.0.0.0/16' |
        Add-PsArmVnetSubnet -Name 'Front-End' -AddressPrefix '10.0.0.0/24' |
        Add-PsArmVnetSubnet -Name 'Back-End' -AddressPrefix '10.0.1.0/24'
$template.resources += $vnet
$template.resources += $vnet2

# Create the Web PublicIP object and add to template
$WebPublicIP = New-PsArmPublicIpAddress -Name 'Web-Pip0' -AllocationMethod Dynamic 
$template.resources += $WebPublicIP

# Create the Web NIC, with references to SubNet and PublicIP, and add to template
$WebNic = New-PsArmNetworkInterface -Name 'Web-Nic0' `
    -SubnetId $vNet.SubnetId('Front-End') `
    -PublicIpAddressId $WebPublicIp.Id() 
$WebNic.dependsOn += $vNet.Id()
$template.resources += $WebNic

# VMs require storege
$Storage = New-PsArmStorageAccount -Name 'myrgdemostorage' -Tier 'Standard' `
        -Replication 'LRS' -Location $location
$template.resources += $Storage

$UserName='pburkholder'
$Password='3nap-sn0t-RR'

# Add the WebVM
$WebVM = New-PsArmVMConfig -VMName 'MyWebServer' -VMSize 'Standard_DS1_V2' |
        Set-PsArmVMOperatingSystem -Windows -ComputerName 'MyWebServer' `
            -AdminUserName $UserName -AdminPassword $Password -ProvisionVMAgent -EnableAutoUpdate |
        Set-PsArmVMSourceImage -Publisher MicrosoftWindowsServer `
            -Offer WindowsServer -Sku 2012-R2-Datacenter -Version "latest" |
        Add-PsArmVMNetworkInterface -Id $WebNic.Id() |
        Set-PsArmVMOSDisk -Name 'MyWebServer_osdisk' -Caching 'ReadWrite' `
            -CreateOption 'FromImage' -SourceImage $null `
            -VhdUri 'https://myrgdemostorage.blob.core.windows.net/vhds/MyWebServer_osdisk.vhd' |
        Add-PsArmVmDependsOn -Id $Storage.Id()
$Template.resources += $WebVM

# Add the DBVM - First the Nic:
$DbNic = New-PsArmNetworkInterface -Name 'Db-Nic0' `
    -SubnetId $vNet.SubnetId('Back-End')
$DbNic.dependsOn += $vNet.id()     
$template.resources += $DbNic

$DbVM = New-PsArmVMConfig -VMName 'MyDbServer' -VMSize 'Standard_DS2_V2' |
        Set-PsArmVMOperatingSystem -Windows -ComputerName 'MyDbServer' `
            -AdminUserName $UserName -AdminPassword $Password -ProvisionVMAgent -EnableAutoUpdate |
        Set-PsArmVMSourceImage -Publisher MicrosoftWindowsServer `
            -Offer WindowsServer -Sku 2012-R2-Datacenter -Version "latest" |
        Add-PsArmVMNetworkInterface -Id $DbNic.Id() |
        Set-PsArmVMOSDisk -Name 'MyDbServer_osdisk' -Caching 'ReadWrite' `
            -CreateOption 'FromImage' -SourceImage $null `
            -VhdUri 'https://myrgdemostorage.blob.core.windows.net/vhds/MyDbServer_osdisk.vhd' |
        Add-PsArmVmDependsOn -Id $Storage.Id()
$template.resources += $DbVM

# Template is complete, now deploy it:
$resourceGroupName = 'MyRG'
$templatefile = $resourceGroupName + '.json'
if ($path) {
    $templatefile = $Path
}
$deploymentName = $resourceGroupName + $(get-date -f yyyyMMddHHmmss)
Save-PsArmTemplate -Template $template -TemplateFile $templatefile

if ($RunIt) {
  New-AzureRmResourceGroup -Name $ResourceGroupName -Location $location -Force
  New-AzureRmResourceGroupDeployment -Name $deploymentName -Mode Complete -Force `
    -ResourceGroupName $ResourceGroupName -TemplateFile $templateFile -Verbose
}
