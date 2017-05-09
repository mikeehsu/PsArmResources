# A DRY version of FirstVirtual.ps1
param( 
 [switch] $RunIt,
 [string] $Path
)
Import-Module "PsArmResources" -Force
Set-StrictMode -Version latest
$ErrorActionPreference = "Stop"

function New-StandardVM() {
    [CmdletBinding()]
    Param (
        [parameter(Mandatory=$False)] [string] $VMName = "MyVM",
        [parameter(Mandatory=$False)] [string] $VMSize = "Standard_DS1_V2",
        [parameter(Mandatory=$True)] $Storage,
        [parameter(Mandatory=$True)] [string] $UserName,
        [parameter(Mandatory=$True)] [string] $Password,
        [parameter(Mandatory=$True)] [string] $NicID
    )
    
    $OsDiskName = "{0}_osdisk" -f $VMName
    $OsVhdUri =  "https://{0}.blob.core.windows.net/vhds/{1}.vhd" -f $Storage.name,$OsDiskName
    New-PsArmVMConfig -VMName $VMName -VMSize $VMSize |
        Set-PsArmVMOperatingSystem -Windows -ComputerName $VMName `
            -AdminUserName $UserName -AdminPassword $Password -ProvisionVMAgent -EnableAutoUpdate |
        Set-PsArmVMSourceImage -Publisher MicrosoftWindowsServer `
            -Offer WindowsServer -Sku 2012-R2-Datacenter -Version "latest" |
        Add-PsArmVMNetworkInterface -Id $NicId |
        Set-PsArmVMOSDisk -Name $OsDiskName -Caching 'ReadWrite' `
            -CreateOption 'FromImage' -SourceImage $null `
            -VhdUri $OsVhdUri |
        Add-PsArmVmDependsOn -Id $Storage.Id()
}

$location = "EastUS"
$template = New-PsArmTemplate

$vNet =  New-PsArmVnet -Name 'MyVNet' -AddressPrefixes '10.0.0.0/16' |
        Add-PsArmVnetSubnet -Name 'Front-End' -AddressPrefix '10.0.0.0/24' |
        Add-PsArmVnetSubnet -Name 'Back-End' -AddressPrefix '10.0.1.0/24'
$template.resources += $vnet

$WebPublicIP = New-PsArmPublicIpAddress -Name 'Web-Pip0' -AllocationMethod Dynamic 
$template.resources += $WebPublicIP

$WebNic = New-PsArmNetworkInterface -Name 'Web-Nic0' `
    -SubnetId $vNet.SubnetId('Front-End') `
    -PublicIpAddressId $WebPublicIp.Id() 
$WebNic.dependsOn += $vNet.Id()
$template.resources += $WebNic

$Storage = New-PsArmStorageAccount -Name 'myrgdemostorage' -Tier 'Standard' `
        -Replication 'LRS' -Location $location
$template.resources += $Storage

$UserName='pburkholder'
$Password='3nap-sn0t-RR'
$WebVM = New-StandardVM -VMName 'MyWebServer' -UserName $UserName -Password $Password `
    -NicId $WebNic.Id() -Storage $Storage
$Template.resources += $WebVM

$DbNic = New-PsArmNetworkInterface -Name 'Db-Nic0' `
    -SubnetId $vNet.SubnetId('Back-End')
$DbNic.dependsOn += $vNet.id()     
$template.resources += $DbNic

$DbVM = New-StandardVM -VMName 'MyDbServer' -VMSize 'Standard_DS2_V2' -UserName $UserName -Password $Password `
            -NicId $DbNic.Id() -Storage $Storage
$template.resources += $DbVM

$resourceGroupName = 'MyRG'

$templatefile = $resourceGroupName + '.json'
if ($Path) {
    $templatefile = $Path
}
$deploymentName = $resourceGroupName + $(get-date -f yyyyMMddHHmmss)
Save-PsArmTemplate -Template $template -TemplateFile $templatefile

if ($RunIt) {
  New-AzureRmResourceGroup -Name $ResourceGroupName -Location $location -Force
  New-AzureRmResourceGroupDeployment -Name $deploymentName -Mode Complete -Force `
    -ResourceGroupName $ResourceGroupName -TemplateFile $templateFile -Verbose
}
