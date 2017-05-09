
# PsArmResources - Powershell module to create ARM templates
#
# Written in 2016 by Mike Hsu
#
# To the extent possible under law, the author(s) have dedicated all copyright 
# and related and neighboring rights to this software to the public domain worldwide.
# This software is distributed without any warranty.
# 
# You should have received a copy of the CC0 Public Domain Dedication along with
# this software. If not, see <http://creativecommons.org/publicdomain/zero/1.0/>.
#

Set-StrictMode -Version Latest

# base class for Id

Class PsArmId {
    [string] $id
}

Class PsArmName {
    [string] $name
}

# ipconfig
Class PsArmIpConfigProperties {
    [string] $privateIPAddress
    [string] $privateIpAllocationMethod = "Dynamic"
    [PsArmId] $publicIpAddress
    [PsArmId] $subnet
    [array] $loadBalancerBackendAddressPools = @()
    [array] $loadBalancerInboundNatRules = @()
}

Class PsArmIpConfig {
    [string] $name
    [PsArmIpConfigProperties] $properties
}

# storage accounts
Class PsArmStorageSku {
    [string] $name
    [string] $tier
}

Class PsArmStorageAccount {
    [string] $apiVersion = '2016-01-01'
    [string] $type = 'Microsoft.Storage/storageAccounts'
    [string] $name
    [string] $location = '[resourceGroup().location]'
    [hashtable] $tags
    [PsArmStorageSku] $sku
    [string] $kind = 'Storage'
    [string] Id() {
        return "[resourceId('{0}', '{1}')]"  -f $this.type,$this.name
    }
}

# Security Group

Class PsArmNetworkSecurityGroupRuleProperties {
    [string] $description
    [string] $protocol = '*'
    [string] $sourceAddressPrefix = '*'
    [string] $sourcePortRange = '*'
    [string] $destinationAddressPrefix ='*'
    [string] $destinationPortRange = '*'
    [string] $access
    [int] $priority
    [string] $direction
}

Class PsArmNetworkSecurityGroupRule {
    [string] $name
    [PsArmNetworkSecurityGroupRuleProperties] $properties
}

Class PsArmNetworkSecurityGroupProperties {
    [array] $securityRules
}

Class PsArmNetworkSecurityGroup {
    [string] $type = 'Microsoft.Network/networkSecurityGroups'
    [string] $apiVersion = '2016-03-30'
    [string] $name
    [string] $location = '[resourceGroup().location]'
    [hashtable] $tags
    [PsArmNetworkSecurityGroupProperties] $properties
}

# Public Ip

Class PsArmPublicIpAddressDnsSettings {
    [string] $domainNameLabel
    [string] $fqdn
    [string] $reverseFqdn
}

Class PsArmPublicIpAddressProperties {
    [string] $publicIPAllocationMethod = 'Dynamic'
    [int] $idleTimeoutInMinutes = 4
    [PsArmPublicIpAddressDnsSettings] $dnsSettings
    [string] $enableIPForwarding = 'False'
}

Class PsArmPublicIpAddress {
    [string] $comments
    [string] $type = 'Microsoft.Network/publicIPAddresses'
    [string] $name
    [string] $apiVersion = '2016-03-30'
    [string] $location = '[resourceGroup().location]'
    [hashtable] $tags
    [PsArmPublicIpAddressProperties] $properties
    [array] $resources = @()
    [array] $dependsOn = @()
    [string] Id() {
       return "[resourceId('{0}', '{1}')]"  -f $this.type,$this.name
    }
}

# Network Interface Classes

Class PsArmNetworkInterfaceDnsSetting {
    [array] $dnsServers = @()
}

Class PsArmNetworkInterfaceProperties {
    [array] $ipConfigurations = @()
    [PsArmNetworkInterfaceDnsSetting] $dnsSettings
    [string] $enableIpFowarding = "false"
    [PsArmId] $networkSecurityGroup
}

Class PsArmNetworkInterface {
    [string] $comments = ""
    [string] $name
    [string] $type = 'Microsoft.Network/networkInterfaces'
    [PsArmNetworkInterfaceProperties] $properties
    [string] $apiVersion = '2016-03-30'
    [string] $location = '[resourceGroup().location]'
    [hashtable] $tags
    [array] $resources = @()
    [array] $dependsOn = @()
    [string] Id() {
       return "[resourceId('{0}', '{1}')]"  -f $this.type,$this.name
    }
}


# Vm Classes

Class PsArmVmExtensionCustomPropertiesSetting {
    [array] $fileUris = @()
}

Class PsArmVmExtensionCustomPropertiesProtectedSettings {
    [string] $commandToExecute
    [string] $storageAccountName
    [string] $storageAccountKey
}

Class PsArmVmExtensionCustomProperties {
    [string] $publisher = 'Microsoft.Compute'
    [string] $type = 'CustomScriptExtension'
    [string] $typeHandlerVersion = '1.7'
    [PsArmVmExtensionCustomPropertiesSetting] $settings
    [PsArmVmExtensionCUstomPropertiesProtectedSettings] $protectedSettings
}

Class PsArmVmExtensionCustom {
    [string] $apiVersion = '2016-03-30'
    [string] $type = 'Microsoft.Compute/virtualMachines/extensions'
    [string] $name
    [string] $location = '[resourceGroup().location]'
    [array] $dependsOn = @()
    [PsArmVmExtensionCustomProperties] $properties
}

# VM extension - join domain

Class PsArmVmExtensionJoinDomainSettings {
    [string] $Name
    [string] $OUPath = ''
    [string] $User
    [string] $Restart = 'true'
    [string] $Options = 3
}

Class PsArmVmExtensionJoinDomainProtected {
    [string] $Password = ''
}

Class PsArmVmExtensionJoinDomainProperties {
    [string] $publisher = 'Microsoft.Compute'
    [string] $type = 'JsonADDomainExtension'
    [string] $typeHandlerVersion = '1.3'
    [PsArmVmExtensionJoinDomainSettings] $settings = [PsArmVmExtensionJoinDomainSettings]::New()
    [PsArmVmExtensionJoinDomainProtected] $protectedsettings = [PsArmVmExtensionJoinDomainProtected]::New()
}

Class PsArmVmExtensionJoinDomain {
    [string] $type = 'Microsoft.Compute/virtualMachines/extensions'
    [string] $apiVersion = '2016-03-30'
    [string] $name
    [string] $location = '[resourceGroup().location]'
    [array] $dependsOn = @()
    [PsArmVmExtensionJoinDomainProperties] $properties = [PsArmVmExtensionJoinDomainProperties]::New()
}

# Availability Set

Class PsArmAvailabilitySetProperties {
    [int] $platformFaultDomainCount
    [int] $platformUpdateDomainCount
}

Class PsArmAvailabilitySet {
    [string] $apiVersion = '2016-03-30'
    [string] $type = 'Microsoft.Compute/availabilitySets'
    [string] $name
    [string] $location = '[resourceGroup().location]'
    [hashtable] $tags
    [array] $dependsOn = @()
    [PsArmAvailabilitySetProperties] $properties
}

# Load Balancers

Class PsArmLoadBalancerInboundNatRuesProperties {
    [PsArmId] $frontendIpConfiguration
    [string] $protocol
    [int] $frontEndPort
    [int] $backendPort
    [bool] $enableFloatingIP
}

Class PsArmLoadBalancerInboundNatRules {
    [string] $name
    [PsArmLoadBalancerInboundNatRuesProperties] $properties
}

Class PsArmLoadBalancerLoadBalancingRulesProperties {
    [PsArmId] $frontendIPConfiguration
    [PsArmId] $backendAddressPool
    [string] $protocol
    [int] $frontendPort
    [int] $backendPort
    [bool] $enableFloatingIP
    [int] $idleTimeoutInMinutes
    [PsArmId] $probe
}

Class PsArmLoadBalancerLoadBalancingRule {
    [string] $name
    [PsArmLoadBalancerLoadBalancingRulesProperties] $properties = [PsArmLoadBalancerLoadBalancingRulesProperties]::New()
}

Class PsArmLoadBalancerProbeProperties {
    [string] $protocol
    [int] $port
    [int] $intervalInSeconds
    [int] $timeoutInSeconds
    [int] $numberOfProbes
}

Class PsArmLoadBalancerProbe {
    [string] $name
    [PsArmLoadBalancerProbeProperties] $properties = [PsArmLoadBalancerProbeProperties]::New()
}

Class PsArmLoadBalancerProperties {
    [array] $frontendIPConfigurations = @()
    [array] $backendAddressPools = @()
    [array] $inboundNatRules = @()
    [array] $loadbalancingRules = @()
    [array] $probes = @()
}

Class PsArmLoadBalancer {
    [string] $apiVersion = '2016-03-30'
    [string] $type = 'Microsoft.Network/loadBalancers'
    [string] $name
    [string] $location = '[resourceGroup().location]'
    [hashtable] $tags
    [array] $dependsOn = @()
    [PsArmLoadBalancerProperties] $properties = [PsArmLoadBalancerProperties]::New()
}

# Virtual Machines

Class PsArmVmHardwareProfile {
    [string] $vmSize
}

Class PsArmVmStorageUri {
    [string] $uri
}

Class PsArmVmStorageImageReference {
    [string] $publisher
    [string] $offer
    [string] $sku
    [string] $version
}

Class PsArmVmStorageOsDisk {
    [string] $name
    [string] $createOption
    [string] $osType
    [PsArmVmStorageUri] $image
    [PsArmVmStorageUri] $vhd
    [string] $caching
}

Class PsArmVmStorageDataDisk {
    [string] $name
    [int] $diskSizeGB
    [int] $lun
    [string] $createOption = ''
    [PsArmVmStorageUri] $image
    [PsArmVmStorageUri] $vhd
    [string] $caching
}

Class PsArmVmStorageProfile {
    [PsArmVmStorageImageReference] $imageReference
    [PsArmVmStorageOsDisk] $osDisk
    [array] $dataDisks = @()
}

Class PsArmVmNetworkInterfaceId {
    [string] $id
}

Class PsArmVmNetworkProfile {
    [array] $networkInterfaces = @()
}

Class PsArmVmOsWindowsConfiguration {
    [string] $provisionVMAgent
    [string] $enableAutomaticUpdates
}


Class PsArmVmOsProfile {
    [string] $computerName
    [string] $adminUserName
    [string] $adminPassword
    [PsArmVmOsWindowsConfiguration] $windowsConfiguration
    [array] $secrets = @()
}


Class PsArmVmProperties {
    [PsArmId] $availabilitySet
    [PsArmVmHardwareProfile] $hardwareProfile
    [PsArmVmStorageProfile] $storageProfile = [PsArmVmStorageProfile]::New()
    [PsArmVmOsProfile] $osProfile
    [PsArmVmNetworkProfile] $networkProfile
}

Class PsArmVmPlan {
    [string] $name
    [string] $product
    [string] $publisher
}

Class PsArmVm {
    [string] $comments = ""
    [string] $type = 'Microsoft.Compute/virtualMachines'
    [string] $name
    [string] $apiVersion = '2015-06-15'
    [string] $location = '[resourceGroup().location]'
    [hashtable] $tags
    [PsArmVmPlan] $plan
    [PsArmVmProperties] $properties
    [array] $resources = @()
    [array] $dependsOn = @()
}

# Vnet Classes

Class PsArmAddressSpace {
    [array] $addressPrefixes
}

Class PsArmSubnetProperties {
    [string] $addressPrefix
    [PsArmId] $networkSecurityGroup
    [PsArmId] $routeTable
}

Class PSArmSubnets {
    [string] $name
    [PsArmSubnetProperties] $properties
}

Class PsArmVnetProperties {
    [PsArmAddressSpace] $addressSpace
    [array] $subnets
}

Class PsArmVnet {
    [string] $type = 'Microsoft.Network/virtualNetworks'
    [string] $apiVersion = '2015-06-15'
    [string] $name
    [string] $location = '[resourceGroup().location]'
    [hashtable] $tags
    [string] $comments
    [array] $dependsOn
    [PsArmVnetProperties] $properties
    [string] SubnetId([string] $SubnetName) {
       return "[concat(resourceId('{0}', '{1}'), '/subnets/{2}')]" -f $this.type,$this.name,$SubnetName
    }
    [string] Id() {
       return "[resourceId('{0}', '{1}')]"  -f $this.type,$this.name
    }

}

# virtual Network Gateways

Class PsArmVnetGatewaySku {
    [string] $name = 'HighPerformance'
    [string] $tier = 'HighPerformance'
}

Class PsArmVnetGatewayProperties {
    [array] $ipConfigurations = @()
    [string] $gatewayType = 'Vpn'
    [PsArmVnetGatewaySku] $sku
    [string] $vpnType = 'RouteBased'
    [string] $enableBgp = 'false'
}

Class PsArmVnetGateway {
    [string] $type = 'Microsoft.Network/virtualNetworkGateways'
    [string] $apiVersion = '2016-03-30'
    [string] $name
    [string] $location = '[resourceGroup().location]'
    [hashtable] $tags
    [array] $dependsOn
    [PsArmVNetGatewayProperties] $properties = [PsArmVnetGatewayProperties]::New()
}

# User Defined Routes

Class PsArmRouteProperties {
    [string] $addressPrefix
    [string] $nextHopType
    [string] $nextHopIpAddress
}

Class PsArmRoute {
    [string] $name
    [PsArmRouteProperties] $properties
}

Class PsArmRouteTableProperties {
    [array] $routes  = @()
}

Class PsArmRouteTable {
    [string] $type = 'Microsoft.Network/routeTables'
    [string] $apiVersion = '2016-03-30'
    [string] $name
    [string] $location = '[resourceGroup().location]'
    [hashtable] $tags
    [PsArmRouteTableProperties] $properties
}


# Local Network Gateway

Class PsArmLocalNetworkAddressSpace {
    [array] $addressPrefixes = @()
}

Class PsArmLocalNetworkGatewayProperties {
    [PsArmLocalNetworkAddressSpace] $localNetworkAddressSpace = [PsArmLocalNetworkAddressSpace]::New()
    [string] $gatewayIpAddress
}

Class PsArmLocalNetworkGateway {
    [string] $type = 'Microsoft.Network/localNetworkGateways'
    [string] $apiVersion = '2016-03-30'
    [string] $name
    [string] $location = '[resourceGroup().location]'
    [hashtable] $tags
    [PsArmLocalNetworkGatewayProperties] $properties = [PsArmLocalNetworkGatewayProperties]::New()
}

Class PsArmConnectionProperties {
    [PsArmId] $virtualNetworkGateway1
    [PsArmId] $virtualNetworkGateway2
    [PsArmId] $localNetworkGateway2
    [string] $connectionType
    [int] $routingWeight
    [string] $sharedkey
}

Class PsArmConnection {
    [string] $type = 'Microsoft.Network/connections'
    [string] $apiVersion = '2016-03-30'
    [string] $name
    [string] $location = '[resourceGroup().location]'
    [hashtable] $tags
    [PsArmConnectionProperties] $properties = [PsArmConnectionProperties]::New()
    [array] $dependsOn
}

# Virtual Network Peering

Class PsArmVirtualNetworkPeeringProperties {
    [bool] $allowVirtualNetworkAccess = $True
    [bool] $allowForwardedTraffic = $False
    [bool] $allowGatewayTransit = $False
    [bool] $useRemoteGateways = $False
    [PsArmId] $remoteVirtualNetwork
}

Class PsArmVirtualNetworkPeering {
    [string] $type = 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings'
    [string] $apiVersion = '2016-06-01'
    [string] $name
    [string] $location = '[resourceGroup().location]'
    [hashtable] $tags
    [PsArmVirtualNetworkPeeringProperties] $properties = [PsArmVirtualNetworkPeeringProperties]::New()
    [array] $dependsOn
}

# template

Class PsArmTemplate {
    [string] $schema =  "https://schema.management.azure.com/schemas/2015-01-01/deploymentTemplate.json#"
    [string] $contentVersion =  "1.0.0.0"
    [array] $resources = @()
}

#######################################m################################

Function Get-PsArmResourceId
{
     Param (
            [parameter(Mandatory=$True, Position=0, ValueFromPipeline=$True, ValueFromPipelineByPropertyName=$True)]
            $Resource,

            [parameter(Mandatory=$False)]
            [string] $subpart
     )

    Write-Output  "[resourceId('$($Resource.Type)', '$($Resource.Name)')]"
}

#######################################m################################

Function New-PsArmId
{
    [CmdletBinding()]

    Param (
        [parameter(Mandatory=$False)]
        [string] $ResourceType,

        [parameter(Mandatory=$False)]
        [string] $ResourceName,

        [parameter(Mandatory=$False)]
        [string] $SubresourceName,

        [parameter(Mandatory=$False)]
        [string] $ResourceId
    )

    $armId = [PsArmId]::New()

    if ($ResourceId) {
        $armId.id = $ResourceId

    } elseif ($ResourceType -and $ResourceName) {
        if ($SubresourceName) {
            $armId.id = "[concat(resourceId('$resourceType', '$ResourceName'), '$SubresourceName')]"
        } else {
            $armId.id = "[resourceId('$resourceType', '$ResourceName')]"
        }

    } else {
        Write-Error "Invalid parameter combination"
    }

    return $armId
}

#######################################m################################

Function New-PsArmName
{
    [CmdletBinding()]

    Param (
        [parameter(Mandatory=$True)]
        [string] $Name
    )

    $x = [PsArmName]::New()
    $x.name = $Name

    return $x
}

#######################################m################################

Function New-PsArmAvailabilitySet
{
    [CmdletBinding()]

    Param (
        [parameter(Mandatory=$True)]
        [string] $Name,

        [parameter(Mandatory=$True)]
        [string] $Location,

        [parameter(Mandatory=$False)]
        [hashtable] $tags,

        [parameter(Mandatory=$False)]
        [string] $FaultDomainCount = 3,

        [parameter(Mandatory=$False)]
        [string] $UpdateDomainCount = 5
    )

    Write-Verbose "Scripting AvailabilitySet $Name"
    $availabilitySet = [PsArmAvailabilitySet]::New()
    $availabilitySet.name = $Name
    $availabilitySet.location = $Location

    if ($tags) {
        $availabilitySet.tags = $tags
    }

    $availabilitySet.properties = [PsArmAvailabilitySetProperties]::New()
    $availabilitySet.properties.platformFaultDomainCount = $FaultDomainCount
    $availabilitySet.properties.platformUpdateDomainCount = $UpdateDomainCount

    return $availabilitySet
}

#######################################m################################

Function New-PsArmNetworkSecurityGroup
{
    [CmdletBinding()]

    Param (
        [parameter(Mandatory=$True)]
        [string] $Name,

        [parameter(Mandatory=$False)]
        [string] $Location,

        [parameter(Mandatory=$False)]
        [hashtable] $tags
    )

    Write-Verbose "Scripting NetworkSecurityGroups $Name"

    # create the Nsg
    $nsg = [PsArmNetworkSecurityGroup]::New()
    $nsg.name = $Name

    if ($Location) {
       $nsg.location = $Location
    }

    if ($tags) {
        $nsg.tags = $tags
    }

    return $nsg
}

#######################################m################################

Function Add-PsArmNetworkSecurityGroupRule
{
    [CmdletBinding()]

    Param (
        [parameter(Mandatory=$True, Position=0, ValueFromPipeline=$True, ValueFromPipelineByPropertyName=$True)]
        [PsArmNetworkSecurityGroup] $nsg,

        [parameter(Mandatory=$True)]
        [string] $Name,

        [parameter(Mandatory=$False)]
        [string] $Description = '',

        [parameter(Mandatory=$True)]
        [int] $Priority,

        [parameter(Mandatory=$True)]
        [string] $Access,

        [parameter(Mandatory=$True)]
        [string] $Direction,

        [parameter(Mandatory=$False)]
        [string] $Protocol,

        [parameter(Mandatory=$False)]
        [string] $SourceAddressPrefix = '*',

        [parameter(Mandatory=$False)]
        [string] $SourcePortRange = '*',

        [parameter(Mandatory=$False)]
        [string] $DestinationAddressPrefix = '*',

        [parameter(Mandatory=$False)]
        [string] $DestinationPortRange = '*'
    )

    Write-Verbose "Scripting NetworkSecurityGroupRule $Name"

    if (-not $nsg.properties) {
        $nsg.properties = [PsArmNetworkSecurityGroupProperties]::New()
    }

    if (-not $Protocol) {
        $Protocol = '*'
    }

    # create the rule
    $rule = [PsArmNetworkSecurityGroupRule]::New()
    $rule.name = $Name
    $rule.properties = [PsArmNetworkSecurityGroupRuleProperties]::New()
    $rule.properties.description              = $Description
    $rule.properties.priority                 = $Priority
    $rule.properties.direction                = $Direction
    $rule.properties.access                   = $Access
    $rule.properties.protocol                 = $Protocol
    $rule.properties.sourceAddressPrefix      = $SourceAddressPrefix
    $rule.properties.sourcePortRange          = $SourcePortRange
    $rule.properties.destinationAddressPrefix = $DestinationAddressPrefix
    $rule.properties.destinationPortRange     = $DestinationPortRange

    $nsg.properties.securityRules += $rule

    return $nsg
}

#######################################m################################

Function New-PsArmNetworkInterface
{
    [CmdletBinding()]

    Param (
        [parameter(Mandatory=$True)]
        [string] $Name,

        [parameter(Mandatory=$False)]
        [string] $Location = '[resourceGroup().location]',

        [parameter(Mandatory=$False)]
        [hashtable] $tags,

        [parameter(Mandatory=$False)]
        [array] $DnsServer,

        [parameter(Mandatory=$False)]
        [switch] $EnableIPForwarding,

        [parameter(Mandatory=$False)]
        [string] $NetworkSecurityGroupId,

        [parameter(Mandatory=$True)]
        [string] $SubnetId,

        [parameter(Mandatory=$False)]
        [string] $PublicIpAddressId,

        [parameter(Mandatory=$False)]
        [string] $PrivateIpAddress,

        [parameter(Mandatory=$False)]
        [string] $IpConfigName = "$($Name)IpConfig"
    )

    Write-Verbose "Scripting NIC $Name on $SubnetId"

    # create the Nic
    $nic = [PsArmNetworkInterface]::New()
    $nic.comments = ''
    $nic.name = $Name
    $nic.location = $Location
    $nic.properties = [PsArmNetworkInterfaceProperties]::New()

    if ($tags) {
        $nic.tags = $tags
    }

    # assign all ipConfiguration settings
    $ipConfig = [PsArmIpConfig]::New()
    $ipConfig.name = "$($Name)Config"
    $ipConfig.properties = [PsArmIpConfigProperties]::New()

    if ($PrivateIpAddress -and $PrivateIpAddress -ne '') {
        $ipConfig.properties.privateIpAddress = $StaticIpAddress
        $ipConfig.properties.privateIpAllocationMethod = 'Static'
    }

    # associate the PublicIp
    if ($PublicIpAddressId) {
        $ipConfig.properties.publicIpAddress = [PsArmId]::New()
        $ipConfig.properties.publicIpAddress.id = $PublicIpAddressId

        $nic.dependsOn += $PublicIpAddressId
    }

    $ipConfig.properties.subnet = [PsArmId]::New()
    $ipConfig.properties.subnet.id = $SubnetId

    # assign ipconfig to NIC
    $nic.properties.ipConfigurations = @($ipConfig)

    # dns settings
    if ($DnsServer) {
        $nic.properties.dnsSettings = [PsArmNetworkInterfaceDnsSetting]::New()
        $nic.properties.dnsSettings.dnsServers += $DnsServer
    }

    # assign ipforwarding
    if ($EnableIPForwarding) {
        $nic.properties.enableIpFowarding = $enableIPForwarding
    }

    # assign Network Security Group
    if ($NetworkSecurityGroupId) {
        $nic.properties.networkSecurityGroup = [PsArmId]::New()
        $nic.properties.networkSecurityGroup.id = $NetworkSecurityGroupId
        $nic.dependsOn += $NetworkSecurityGroupId
    }

    return $nic
}

#######################################m################################

Function New-PsArmPublicIpAddress
{
    Param(
        [parameter(Mandatory=$True)]
        [string] $Name,

        [parameter(Mandatory=$False)]
        [string] $Location,

        [parameter(Mandatory=$False)]
        [hashtable] $tags,

        [parameter(Mandatory=$False)]
        [string] $DomainNameLabel,

        [parameter(Mandatory=$False)]
        [string] $AllocationMethod

    )

    Write-Verbose "Scripting PublicIp $Name with DNS $DomainNameLabel"

    if (-not $domainNameLabel -cmatch '^[a-z][a-z0-9-]{1,61}[a-z0-9]$' ) {
        Write-Error "VmName name is invalid. It must conform to the following regular expression: ^[a-z][a-z0-9-]{1,61}[a-z0-9]$."
        return
    }

    $pip = [PsArmPublicIpAddress]::New()
    $pip.name = $Name

    if ($Location) {
        $pip.location = $Location
    }

    if ($tags) {
        $pip.tags = $tags
    }

    $pip.properties = [PsArmPublicIpAddressProperties]::New()
    if ($AllocationMethod) {
        $pip.properties.publicIPAllocationMethod = $AllocationMethod
    }

    if ($DomainNameLabel) {
        $pip.properties.dnsSettings = [PsArmPublicIpAddressDnsSettings]::New()
        $pip.properties.dnsSettings.domainNameLabel = $DomainNameLabel
    }

    return $pip
}

#######################################m################################

Function Add-PsArmRoute
{
    [CmdletBinding()]

    Param (
        [parameter(Mandatory=$True,Position=0, ValueFromPipeline=$True, ValueFromPipelineByPropertyName=$True)]
        [PsArmRouteTable] $routeTable,

        [parameter(Mandatory=$True)]
        [string] $Name,

        [parameter(Mandatory=$True)]
        [string] $AddressPrefix,

        [parameter(Mandatory=$True)]
        [string] $NextHopType,

        [parameter(Mandatory=$False)]
        [string] $NextHopIpAddress
    )

    Write-Verbose "Scripting Route $Name"

    if (-not $routeTable.properties) {
        $routeTable.properties = [PsArmRouteTableProperties]::New()
    }

    # create the route
    $route = [PsArmRoute]::New()
    $route.name = $Name

    $route.properties = [PsArmRouteProperties]::New()
    $route.properties.addressPrefix = $AddressPrefix
    $route.properties.nextHopType = $NextHopType
    $route.properties.nextHopIpAddress = $NextHopIpAddress

    $routeTable.properties.routes += $route

    return $routeTable
}

#######################################m################################

Function New-PsArmRouteTable
{
    [CmdletBinding()]

    Param (
        [parameter(Mandatory=$True)]
        [string] $Name,

        [parameter(Mandatory=$False)]
        [string] $Location,

        [parameter(Mandatory=$False)]
        [hashtable] $tags,

        [parameter(Mandatory=$False)]
        [array] $routes
    )

    Write-Verbose "Scripting RouteTable $Name"

    $routeTable = [PsArmRouteTable]::New()
    $routeTable.name = $Name

    if ($Location) {
       $routeTable.location = $Location
    }
    
    if ($tags) {
        $routeTable.tags = $tags
    }

    $routeTable.properties = [PsArmRouteTableProperties]::New()

    return $routeTable
}

#######################################m################################

Function New-PsArmStorageAccount
{
    [CmdletBinding()]

    Param (
        [parameter(Mandatory=$True)]
        [string] $Name,

        [parameter(Mandatory=$True)]
        [string] $Location,

        [parameter(Mandatory=$False)]
        [hashtable] $tags,

        [parameter(Mandatory=$False)]
        [ValidateSet('Standard', 'Premium')]
        [string] $Tier = 'Standard',

        [parameter(Mandatory=$False)]
        [ValidateSet('LRS','GRS','RAGRS','ZRS')]
        [string] $Replication = 'LRS'
    )

    Write-Verbose "Scripting StorageAccount $Name"

    $storageAccount = [PsArmStorageAccount]::New()
    $storageAccount.name = $Name
    $storageAccount.location = $Location

    if ($tags) {
        $storageAccount.tags = $tags
    }

    $storageAccount.sku = [PsArmStorageSku]::New()
    $storageAccount.sku.tier = $Tier
    $storageAccount.sku.name = $Tier + '_' + $Replication

    return $storageAccount
}

#######################################m################################

Function New-PsArmTemplate
{
    [CmdletBinding()]

    Param (
    )

    return [PsArmTemplate]::New()

}

#######################################m################################

Function Save-PsArmTemplate
{

    [CmdletBinding()]

    Param(
        [parameter(Mandatory=$True)]
        [PsArmTemplate] $Template,

        [parameter(Mandatory=$True)]
        [string] $TemplateFile
    )


    Write-Verbose "Saving PsArmTemplate to $templateFile"

    $( ConvertTo-Json $template -Depth 10 ).Replace('\u0027',"'").Replace('"schema":','"$schema":') > $templateFile

}


#######################################m################################

Function New-PsArmVmConfig
{
    [CmdletBinding()]

    Param(
        [parameter(Mandatory=$True)]
        [string] $VmName,

        [parameter(Mandatory=$True)]
        [string] $VmSize,

        [parameter(Mandatory=$False)]
        [string] $Location,

        [parameter(Mandatory=$False)]
        [hashtable] $tags,

        [parameter(Mandatory=$False)]
        [string] $AvailabilitySetId
    )

    Write-Verbose "Scripting VMConfig $VmName"

    $vm = [PsArmVm]::New()
    $vm.name = $VmName

    if ($Location) {
        $vm.location = $Location
    }

    if ($tags) {
        $vm.tags = $tags
    }

    $vm.properties = [PsArmVmProperties]::New()

    # hardwareProfile
    $vm.properties.hardwareProfile = [PsArmVmHardwareProfile]::New()
    $vm.properties.hardwareProfile.vmSize = $VmSize

    if ($AvailabilitySetId) {
        $vm = Set-PsArmAvailabilitySet -VM $vm -Id $AvailabilitySetId
    }

    return $vm
}


#######################################m################################

Function Set-PsArmVmOperatingSystem
{
    [CmdletBinding()]

    Param(
        [parameter(Mandatory=$True, Position=0, ValueFromPipeline=$True, ValueFromPipelineByPropertyName=$True)]
        [PsArmvm] $VM,

        [parameter(Mandatory=$False, Position=1, ValueFromPipeline=$True, ValueFromPipelineByPropertyName=$True)]
        [switch] $Windows,

        [parameter(Mandatory=$True, Position=2, ValueFromPipeline=$True, ValueFromPipelineByPropertyName=$True)]
        [string] $ComputerName,

        [parameter(Mandatory=$False, Position=5, ValueFromPipeline=$True, ValueFromPipelineByPropertyName=$True)]
        [switch] $ProvisionVMAgent,

        [parameter(Mandatory=$False, Position=6, ValueFromPipeline=$True, ValueFromPipelineByPropertyName=$True)]
        [switch] $EnableAutoUpdate,

        # [parameter(Mandatory=$False, Position=6, ValueFromPipeline=$True, ValueFromPipelineByPropertyName=$True)]
        # [string] $TimeZone,

        # [parameter(Mandatory=$False, ValueFromPipeline=$True, ValueFromPipelineByPropertyName=$True)]
        # [switch] $Linux,

        [parameter(Mandatory=$True, ValueFromPipeline=$True, ValueFromPipelineByPropertyName=$True)]
        [string] $AdminUserName,

        [parameter(Mandatory=$True, ValueFromPipeline=$True, ValueFromPipelineByPropertyName=$True)]
        [string] $AdminPassword

    )

    # properties
    if (-not $VM.properties) {
        $vm.properties = [PsArmVmProperties]::New()
    }

    # osProfile
    $VM.properties.osProfile = [PsArmVmOsProfile]::New()
    $VM.properties.osProfile.computerName = $ComputerName
    $VM.properties.osProfile.adminUsername = $AdminUserName
    $VM.properties.osProfile.adminPassword = $AdminPassword

    if ($Windows) {
        $VM.properties.osProfile.windowsConfiguration = [PsArmVmOsWindowsConfiguration]::New()
        $VM.properties.osProfile.windowsConfiguration.provisionVMAgent = $ProvisionVMAgent
        # $VM.properties.osProfile.windowsConfiguration.enableAutomaticUpdates = $EnableAutoUpdate
    }

    return $VM

}

#######################################m################################

Function Add-PsArmVmNetworkInterface
{
    [CmdletBinding()]

    Param(
        [parameter(Mandatory=$True, Position=0, ValueFromPipeline=$True, ValueFromPipelineByPropertyName=$True)]
        [PsArmvm] $VM,

        [parameter(Mandatory=$True, Position=1, ValueFromPipeline=$True, ValueFromPipelineByPropertyName=$True)]
        [String] $Id
    )

    if (-not $VM.properties) {
        $vm.properties = [PsArmVmProperties]::New()
    }

    # networkProfile
    if (-not $VM.properties.networkProfile) {
        $VM.properties.networkProfile = [PsArmVmNetworkProfile]::New()
    }

    $VM.properties.networkProfile.networkInterfaces += New-PsArmId -ResourceId $Id
    $VM.dependsOn += $Id

    return $VM
}

#######################################m################################

Function Add-PsArmVmDataDisk
{
    [CmdletBinding()]

    Param(
        [parameter(Mandatory=$True, Position=0, ValueFromPipeline=$True, ValueFromPipelineByPropertyName=$True)]
        [PsArmVm] $VM,

        [parameter(Mandatory=$True, Position=1, ValueFromPipeline=$True, ValueFromPipelineByPropertyName=$True)]
        [string] $Name,

        [parameter(Mandatory=$False, Position=3, ValueFromPipeline=$True, ValueFromPipelineByPropertyName=$True)]
        [string] $VhdUri,

        [parameter(Mandatory=$False, Position=4, ValueFromPipeline=$True, ValueFromPipelineByPropertyName=$True)]
        [string] $Caching = 'ReadWrite',

        [parameter(Mandatory=$True, Position=6, ValueFromPipeline=$True, ValueFromPipelineByPropertyName=$True)]
        [int] $Lun,

        [parameter(Mandatory=$False, Position=7, ValueFromPipeline=$True, ValueFromPipelineByPropertyName=$True)]
        [string] $CreateOption = 'Empty',

        [parameter(Mandatory=$True, Position=5, ValueFromPipeline=$True, ValueFromPipelineByPropertyName=$True)]
        [int] $DiskSizeInGB,

        [parameter(Mandatory=$False, Position=8, ValueFromPipeline=$True, ValueFromPipelineByPropertyName=$True)]
        [string] $SourceImageUri

    )

    Write-Verbose "Scripting data disk $VhdUri"

    $dataDisk = [PsArmVmStorageDataDisk]::New()
    $dataDisk.name = $Name
    $dataDisk.diskSizeGB = $DiskSizeInGB
    $dataDisk.caching = $Caching
    $dataDisk.lun = $Lun
    $dataDisk.createOption = $CreateOption
    $dataDisk.vhd = [PsArmVmStorageUri]::New()
    $dataDisk.vhd.uri = $VhdUri

    $vm.properties.storageProfile.dataDisks += $dataDisk

    return $VM
}

#######################################m################################

Function Add-PsArmVmDependsOn
{
    [CmdletBinding()]

    Param(
        [parameter(Mandatory=$True, Position=0, ValueFromPipeline=$True, ValueFromPipelineByPropertyName=$True)]
        [PsArmVm] $VM,

        [parameter(Mandatory=$True, Position=1, ValueFromPipeline=$True, ValueFromPipelineByPropertyName=$True)]
        [array] $Id
    )

    $VM.dependsOn += $Id

    return $VM
}

#######################################m################################

Function Set-PsArmVmOsDisk
{
    [CmdletBinding()]

    Param(
        [parameter(Mandatory=$True, Position=0, ValueFromPipeline=$True, ValueFromPipelineByPropertyName=$True)]
        [PsArmVm] $VM,

        [parameter(Mandatory=$True, Position=2, ValueFromPipeline=$True, ValueFromPipelineByPropertyName=$True)]
        [string] $Name,

        [parameter(Mandatory=$True, Position=3, ValueFromPipeline=$True, ValueFromPipelineByPropertyName=$True)]
        [string] $VhdUri,

        [parameter(Mandatory=$False, Position=4, ValueFromPipeline=$True, ValueFromPipelineByPropertyName=$True)]
        [String] $Caching = 'ReadWrite',

        [parameter(Mandatory=$False, Position=5, ValueFromPipeline=$True, ValueFromPipelineByPropertyName=$True)]
        [string] $SourceImageUri,

        [parameter(Mandatory=$True, Position=6, ValueFromPipeline=$True, ValueFromPipelineByPropertyName=$True)]
        [string] $CreateOption = 'FromImage',

        # [parameter(Mandatory=$False, ValueFromPipeline=$True, ValueFromPipelineByPropertyName=$True)]
        # [int] $DiskSizeInGB,

        [parameter(Mandatory=$False, ValueFromPipeline=$True, ValueFromPipelineByPropertyName=$True)]
        [switch] $Windows,

        [parameter(Mandatory=$False, ValueFromPipeline=$True, ValueFromPipelineByPropertyName=$True)]
        [switch] $Linux
    )

    Write-Verbose "Scripting OS disk $VhdUri from $SourceImageUri"

    # onlyl set the osType if copying from an image
    $osType = 'Windows'
    if ($Linux) {
        $osType = 'Linux'
    }

    if (-not $VM.properties.storageProfile) {
        $VM.properties.storageProfile = [PsArmVmStorageProfile]::New()
    }

    $VM.properties.storageProfile.osDisk = [PsArmVmStorageOsDisk]::New()

    if ($SourceImageUri) {
        $VM.properties.storageProfile.osDisk.osType = $osType
        $VM.properties.storageProfile.osDisk.image = [PsArmVmStorageUri]::New()
        $VM.properties.storageProfile.osDisk.image.uri = $SourceImageUri
    }

    $VM.properties.storageProfile.osDisk.name = $Name
    $VM.properties.storageProfile.osDisk.createOption = $CreateOption

    $VM.properties.storageProfile.osDisk.vhd = [PsArmVmStorageUri]::New()
    $VM.properties.storageProfile.osDisk.vhd.uri = $VhdUri
    $VM.properties.storageProfile.osDisk.caching = $Caching

    return $VM
}

#######################################m################################

Function Set-PsArmVmSourceImage
{
    [CmdletBinding()]

    Param(
        [parameter(Mandatory=$True, Position=0, ValueFromPipeline=$True, ValueFromPipelineByPropertyName=$True)]
        [PsArmVm] $VM,

        [parameter(Mandatory=$True, Position=1, ValueFromPipeline=$True, ValueFromPipelineByPropertyName=$True)]
        [string] $Publisher,

        [parameter(Mandatory=$True, Position=2, ValueFromPipeline=$True, ValueFromPipelineByPropertyName=$True)]
        [string] $Offer,

        [parameter(Mandatory=$True, Position=3, ValueFromPipeline=$True, ValueFromPipelineByPropertyName=$True)]
        [string] $Sku,

        [parameter(Mandatory=$True, Position=4, ValueFromPipeline=$True, ValueFromPipelineByPropertyName=$True)]
        [string] $Version
    )

    Write-Verbose "Scripting OS disk from publisher:$Publisher Sku:$Sku"

    if (-not $vm.properties.storageProfile) {
        $vm.properties.storageProfile = [PsArmVmStorageProfile]::New()
    }

    $vm.properties.storageProfile.imageReference = [PsArmVmStorageImageReference]::New()
    $vm.properties.storageProfile.imageReference.publisher = $Publisher
    $vm.properties.storageProfile.imageReference.offer = $Offer
    $vm.properties.storageProfile.imageReference.sku = $Sku
    $vm.properties.storageProfile.imageReference.version = $Version

    return $VM
}


##########################################################################

Function New-PsArmVnet
{
    [CmdletBinding()]

    Param (
        [parameter(Mandatory=$True)]
        [string] $Name,

        [parameter(Mandatory=$False)]
        [string] $Location,

        [parameter(Mandatory=$False)]
        [hashtable] $tags,

        [parameter(Mandatory=$True)]
        [array] $AddressPrefixes

    )

    Write-Verbose "Scripting Virtual Network $Name"

    $vnet = [PsArmVnet]::New()
    $vnet.Name = $Name

    if ($Location) {
        $vnet.Location = $Location
    }

    if ($tags) {
        $vnet.tags = $tags
    }

    $vnet.properties = [PsArmVnetProperties]::New()
    $vnet.properties.addressSpace = [PsArmAddressSpace]::New()
    $vnet.properties.addressSpace.AddressPrefixes = $AddressPrefixes

    return $vnet
}

##########################################################################

Function Add-PsArmVnetSubnet
{
    [CmdletBinding()]

    Param (
        [parameter(Mandatory=$True,Position=0, ValueFromPipeline=$True, ValueFromPipelineByPropertyName=$True)]
        [PsArmVnet] $Vnet,

        [parameter(Mandatory=$True)]
        [string] $Name,

        [parameter(Mandatory=$True)]
        [string] $AddressPrefix,

        [parameter(Mandatory=$False)]
        [string] $NetworkSecurityGroupName,

        [parameter(Mandatory=$False)]
        [string] $RouteTableName
    )

    Write-Verbose "Scripting Subnet $Name"

    if (-not $vnet.properties) {
        $vnet.properties = [PsArmVnetProperties]::New()
    }

    # create a new Subnet
    $subnet = [PsArmSubnets]::New()
    $subnet.name = $Name
    $subnet.properties = [PsArmSubnetProperties]::New()
    $subnet.properties.addressPrefix = $AddressPrefix

    if ($NetworkSecurityGroupName) {
        $subnet.properties.networkSecurityGroup = New-PsArmId -ResourceType 'Microsoft.Network/networkSecurityGroups' -ResourceName $NetworkSecurityGroupName
    }

    if ($RouteTableName) {
        $subnet.properties.routetable = New-PsArmId -ResourceType 'Microsoft.Network/routeTables' -ResourceName $RouteTableName
    }

    $vnet.properties.subnets += $subnet

    return $vnet
}


##########################################################################

Function Get-PsArmVnetSubnetId
{
    [CmdletBinding()]

    Param (
        [parameter(Mandatory=$True, Position=0, ValueFromPipeline=$True, ValueFromPipelineByPropertyName=$True)]
        [PsArmVnet] $Vnet,

        [parameter(Mandatory=$True)]
        [string] $SubnetName
    )

    foreach ($subnet in $Vnet.properties.subnets) {
        if ($subnet.name -eq $SubnetName) {
            $subnetId = New-PsArmId -ResourceType 'Microsoft.Network/virtualNetworks' -ResourceName $($Vnet.Name) -SubResource "/subnets/$($SubnetName)"
            return $subnetId.Id
        }
    }

    Write-Error "Unable to find $SubnetName subnet"
    return ''
}

##########################################################################

Function Set-PsArmVnetNetworkSecurityGroup
{
    Param (
        [parameter(Mandatory=$True,Position=0, ValueFromPipeline=$True, ValueFromPipelineByPropertyName=$True)]
        [PsArmVnet] $vnet,

        [parameter(Mandatory=$True)]
        [string] $NetworkSecurityGroupName,

        [parameter(Mandatory=$False)]
        [array] $SubnetName,

        [parameter(Mandatory=$False)]
        [switch] $ApplyToAllSubnets

    )

    Write-Verbose "Scripting Set Nsg to $NetworkSecurityGroupName for all Subnets in $($vnet.name)"

    # loop through all subnets
    for ($i=0; $i -lt $vnet.properties.subnets.count; $i++) {
        # GatewaySubnet should not have any NSG assigned
        if ($vnet.properties.subnets[$i].name -eq 'GatewaySubnet') {
            continue
        }

        # set the NSG, if applicable
        if ($ApplyToAllSubnets -or ($SubnetName -contains $vnet.properties.subnets[$i].name)) {
            $vnet.properties.subnets[$i].properties.networkSecurityGroup = `
                New-PsArmId -ResourceType 'Microsoft.Network/networkSecurityGroups' -ResourceName $networkSecurityGroupName
        }
    }

    # add dependency to the vnet
    $dependency = "[resourceId('Microsoft.Network/networkSecurityGroups', '$NetworkSecurityGroupName')]"
    if ($vnet.dependsOn -notcontains $dependency) {
        $vnet.dependsOn += $dependency
    }

    return $vnet
}

##########################################################################

Function Set-PsArmVnetRouteTable
{
    Param (
        [parameter(Mandatory=$True,Position=0, ValueFromPipeline=$True, ValueFromPipelineByPropertyName=$True)]
        [PsArmVnet] $vnet,

        [parameter(Mandatory=$True)]
        [string] $RouteTableName,

        [parameter(Mandatory=$False)]
        [array] $SubnetName,

        [parameter(Mandatory=$False)]
        [switch] $ApplyToAllSubnets

    )

    Write-Verbose "Scripting Set RouteTable to $RouteTableName for all Subnets in $($vnet.name)"

    # loop through all subnets
    for ($i=0; $i -lt $vnet.properties.subnets.count; $i++) {
        # ??? Should routes apply to GatewaySubnet?
        if ($vnet.properties.subnets[$i].name -eq 'GatewaySubnet') {
            continue
        }

        # set the RouteTable, if applicable
        if ($ApplyToAllSubnets -or ($SubnetName -contains $vnet.properties.subnets[$i].name)) {
            $vnet.properties.subnets[$i].properties.routeTable = `
                New-PsArmId -ResourceType 'Microsoft.Network/RouteTables' -ResourceName $RouteTableName
        }
    }

    # add dependency to the vnet
    $dependency = "[resourceId('Microsoft.Network/routeTables', '$RouteTableName')]"
    if ($vnet.dependsOn -notcontains $dependency) {
        $vnet.dependsOn += $dependency
    }

    return $vnet
}

##########################################################################

Function New-PsArmVnetGateway
{
    Param (
        [parameter(Mandatory=$True)]
        [string] $Name,

        [parameter(Mandatory=$False)]
        [string] $Location,

        [parameter(Mandatory=$False)]
        [hashtable] $tags,

        [parameter(Mandatory=$True)]
        [string] $VnetName,

        [parameter(Mandatory=$True)]
        [string] $PublicIpAddressName,

        [parameter(Mandatory=$False)]
        [string] $AllocationMethod = 'Dynamic',

        [parameter(Mandatory=$False)]
        [string] $GatewayTier = 'HighPerformance',

        [parameter(Mandatory=$False)]
        [string] $GatewayType = 'Vpn',

        [parameter(Mandatory=$False)]
        [string] $VpnType = 'RouteBased',

        [parameter(Mandatory=$False)]
        [string] $EnableBgp = 'false',

        [parameter(Mandatory=$False)]
        [string] $ipConfigName
    )

    if (-not $ipConfigName) {
        $ipConfigName = $Name + 'IpConfig'
    }


    $ipConfig = [PsArmIpConfig]::New()
    $ipConfig.name = $ipConfigName
    $ipConfig.properties += [PsArmIpConfigProperties]::New()
    $ipConfig.properties.privateIPAllocationMethod = $AllocationMethod
    $ipConfig.properties.subnet = `
        New-PsArmId -ResourceType 'Microsoft.Network/virtualNetworks' -ResourceName $VnetName -SubResource "/subnets/GatewaySubnet"
    $ipConfig.properties.publicIpAddress = `
        New-PsArmId -ResourceType 'Microsoft.Network/publicIPAddresses' -ResourceName $PublicIpAddressName

    $gateway = [PsArmVnetGateway]::New()
    $gateway.name = $Name

    if ($Location) {
        $gateway.location = $Location    
    }

    if ($tags) {
        $gateway.tags = $tags
    }

    $gateway.dependsOn += "[resourceId('Microsoft.Network/virtualNetworks', '$vnetName')]"
    $gateway.properties = [PsArmVnetGatewayProperties]::New()
    $gateway.properties.ipConfigurations += $ipConfig
    $gateway.properties.gatewayType = $GatewayType
    $gateway.properties.sku = [PsArmVnetGatewaySku]::New()
    $gateway.properties.sku.name = $GatewayTier
    $gateway.properties.sku.tier = $GatewayTier
    $gateway.properties.vpnType = $VpnType
    $gateway.properties.enableBgp = $enableBgp

    return $gateway
}

##########################################################################

Function New-PsArmLocalNetworkGateway
{
    [CmdletBinding()]

    Param(
        [parameter(Mandatory=$True, Position=0, ValueFromPipeline=$True, ValueFromPipelineByPropertyName=$True)]
        [string] $Name,

        [parameter(Mandatory=$False, Position=2, ValueFromPipeline=$True, ValueFromPipelineByPropertyName=$True)]
        [string] $Location,

        [parameter(Mandatory=$False)]
        [hashtable] $tags,

        [parameter(Mandatory=$True, Position=3, ValueFromPipeline=$True, ValueFromPipelineByPropertyName=$True)]
        [string] $GatewayIpAddress,

        [parameter(Mandatory=$True, Position=4, ValueFromPipeline=$True, ValueFromPipelineByPropertyName=$True)]
        [array] $AddressPrefix
    )

    Write-Verbose "Scripting Local Network Gateway $Name"

    $localNetworkGateway = [PsArmLocalNetworkGateway]::New()
    $localNetworkGateway.Name = $Name

    if ($Location) {
        $localNetworkGateway.location = $Location
    }

    if ($tags) {
        $localNetworkGateway.tags = $tags
    }

    $localNetworkGateway.properties = [PsArmLocalNetworkGatewayProperties]::New()
    $localNetworkGateway.properties.localNetworkAddressSpace = [PsArmLocalNetworkAddressSpace]::New()
    $localNetworkGateway.properties.localNetworkAddressSpace.AddressPrefixes = $addressPrefix
    $localNetworkGateway.properties.gatewayIpAddress = $GatewayIpAddress
    return $localNetworkGateway
}

##########################################################################

Function New-PsArmVirtualNetworkPeering
{
    [CmdletBinding()]

    Param(
        [parameter(Mandatory=$True, Position=0, ValueFromPipeline=$True, ValueFromPipelineByPropertyName=$True)]
        [string] $Name,

        [parameter(Mandatory=$False, Position=1, ValueFromPipeline=$True, ValueFromPipelineByPropertyName=$True)]
        [string] $Location,

        [parameter(Mandatory=$False)]
        [hashtable] $tags,

        [parameter(Mandatory=$False, Position=2, ValueFromPipeline=$True, ValueFromPipelineByPropertyName=$True)]
        [string] $Vnet1Name,

        [parameter(Mandatory=$True, Position=3, ValueFromPipeline=$True, ValueFromPipelineByPropertyName=$True)]
        [string] $Vnet2Id,

        [parameter(Mandatory=$False)]
        [switch] $allowVirtualNetworkAccess = $False,

        [parameter(Mandatory=$False)]
        [switch] $allowForwardedTraffic = $False,

        [parameter(Mandatory=$False)]
        [switch] $allowGatewayTransit = $False,

        [parameter(Mandatory=$False)]
        [switch] $useRemoteGateways = $False
    )

    Write-Verbose "Scripting Virtual Network Peering $Name"


    $vnetPeer = [PsArmVirtualNetworkPeering]::New()
    $vnetPeer.Name = $($Vnet1Name) + '/' + $($Name)

    if ($Location) {
        $vnetPeer.location = $Location
    }

    if ($tags) {
        $vnetPeer.tags = $tags
    }

    $vnetPeer.properties = [PsArmVirtualNetworkPeeringProperties]::New()
    $vnetPeer.properties.allowVirtualNetworkAccess = $allowVirtualNetworkAccess
    $vnetPeer.properties.allowForwardedTraffic = $allowForwardedTraffic
    $vnetPeer.properties.allowGatewayTransit = $allowGatewayTransit
    $vnetPeer.properties.useRemoteGateways = $useRemoteGateways
    $vnetPeer.properties.remoteVirtualNetwork = New-PsArmId -ResourceId $Vnet2Id
    $vnetPeer.dependsOn += "[resourceId('Microsoft.Network/virtualNetworks', '$($Vnet1Name)')]"

    return $vnetPeer
}

##########################################################################

Function New-PsArmVirtualNetworkGatewayConnection
{
    [CmdletBinding()]

    Param(
        [parameter(Mandatory=$True, Position=0, ValueFromPipeline=$True, ValueFromPipelineByPropertyName=$True)]
        [string] $Name,

        [parameter(Mandatory=$False, Position=2, ValueFromPipeline=$True, ValueFromPipelineByPropertyName=$True)]
        [string] $Location,

        [parameter(Mandatory=$False)]
        [hashtable] $tags,

        [parameter(Mandatory=$True, Position=3, ValueFromPipeline=$True, ValueFromPipelineByPropertyName=$True)]
        [string] $virtualNetworkGateway1Id,

        [parameter(Mandatory=$False, Position=4, ValueFromPipeline=$True, ValueFromPipelineByPropertyName=$True)]
        [string] $virtualNetworkGateway2Id,

        [parameter(Mandatory=$False, Position=4, ValueFromPipeline=$True, ValueFromPipelineByPropertyName=$True)]
        [string] $LocalNetworkGateway2Id,

        [parameter(Mandatory=$True, Position=5, ValueFromPipeline=$True, ValueFromPipelineByPropertyName=$True)]
        [string] $ConnectionType,

        [parameter(Mandatory=$True, Position=6, ValueFromPipeline=$True, ValueFromPipelineByPropertyName=$True)]
        [int] $RoutingWeight,

        [parameter(Mandatory=$True, Position=7, ValueFromPipeline=$True, ValueFromPipelineByPropertyName=$True)]
        [string] $Sharedkey
    )

    Write-Verbose "Scripting Gateway Connection $Name"

    $connection = [PsArmConnection]::New()
    $connection.Name = $Name

    if ($Location) {
        $connection.location = $Location
    }

    if ($tags) {
        $connection.tags = $tags
    }

    $connection.properties = [PsArmConnectionProperties]::New()
    $connection.properties.virtualNetworkGateway1 = New-PsArmId -ResourceId $virtualNetworkGateway1Id
    # $connection.dependsOn += $virtualNetworkGateway1Id

    if ($ConnectionType -eq 'IPSec') {
        $connection.properties.localNetworkGateway2 = New-PsArmId -ResourceId $LocalNetworkGateway2Id
        # $connection.dependsOn += $LocalNetworkGateway2Id

    } elseif ($ConnectionType -eq 'Vnet2Vnet') {
        $connection.properties.virtualNetworkGateway2 = New-PsArmId -ResourceId $virtualNetworkGateway2Id
        # $connection.dependsOn += $virtualNetworkGateway2Id

    } else {
        Write-Error 'Invalid connectionType of $ConnectionType provided.'
        return
    }

    $connection.properties.connectionType = $connectionType
    $connection.properties.routingWeight = $RoutingWeight
    $connection.properties.sharedKey = $sharedkey

    return $connection
}

##########################################################################

Function Set-PsArmAvailabilitySet
{
    [CmdletBinding()]

    Param(
        [parameter(Mandatory=$True, Position=0, ValueFromPipeline=$True, ValueFromPipelineByPropertyName=$True)]
        [PsArmVm] $VM,

        [parameter(Mandatory=$True, Position=1, ValueFromPipeline=$True, ValueFromPipelineByPropertyName=$True)]
        [string] $Id
    )

    $VM.properties.availabilitySet = [PsArmId]::New()
    $VM.properties.availabilitySet.id = $Id
    $VM.dependsOn += $Id

    return $VM
}


##########################################################################

Function New-PsArmVmCustomScriptExtension
{
    [CmdletBinding()]

    Param(
        [parameter(Mandatory=$True, Position=0, ValueFromPipeline=$True, ValueFromPipelineByPropertyName=$True)]
        [string] $VmName,

        [parameter(Mandatory=$True, Position=1, ValueFromPipeline=$True, ValueFromPipelineByPropertyName=$True)]
        [string] $CustomExtensionUri,

        [parameter(Mandatory=$True, Position=2, ValueFromPipeline=$True, ValueFromPipelineByPropertyName=$True)]
        [string] $StorageAccountName,

        [parameter(Mandatory=$True, Position=3, ValueFromPipeline=$True, ValueFromPipelineByPropertyName=$True)]
        [string] $StorageAccountKey,

        [parameter(Mandatory=$False, Position=4, ValueFromPipeline=$True, ValueFromPipelineByPropertyName=$True)]
        [string] $Run
    )

    $uriParts = $CustomExtensionUri.Split('/')
    $uriStorageAccountName = $uriParts[2].Split('.')[0]
    $uriContainer = $uriParts[3]
    $uriBlobName = $uriParts[4..$($uriParts.Count-1)] -Join '/'

    if (-not $Run) {
        $Run = "powershell -ExecutionPolicy Unrestricted -File $uriBlobName"
    }

    $ext = [PsArmVmExtensionCustom]::New()
    $ext.name = $VmName + "/CustomScriptExtension"
    $ext.location = '[resourceGroup().location]'
    $ext.dependsOn += "[resourceId('Microsoft.Compute/virtualMachines', '$($VmName)')]"

    $ext.properties = [PsArmVmExtensionCustomProperties]::New()
    $ext.properties.settings = [PsArmVmExtensionCustomPropertiesSetting]::New()
    $ext.properties.settings.fileUris += $CustomExtensionUri
    $ext.properties.protectedSettings = [PsArmVmExtensionCUstomPropertiesProtectedSettings]::New()
    $ext.properties.protectedSettings.commandToExecute = $Run
    $ext.properties.protectedSettings.storageAccountName = $StorageAccountName
    $ext.properties.protectedSettings.storageAccountKey = $StorageAccountKey

    $ext
}

##########################################################################

Function New-PsArmLoadBalancer
{
    [CmdletBinding()]

    Param (
        [parameter(Mandatory=$True)]
        [string] $Name,

        [parameter(Mandatory=$False)]
        [string] $Location,

        [parameter(Mandatory=$False)]
        [hashtable] $tags
    )

    $loadBalancer = [PsArmLoadBalancer]::New()
    $loadBalancer.name = $Name

    if ($Location) {
        $loadBalancer.location = $Location        
    }

    if ($tags) {
        $loadBalancer.tags = $tags
    }

    return $loadBalancer
}

##########################################################################

Function Add-PsArmLoadBalancerFrontEndIpConfiguration
{
    [CmdletBinding()]

    Param (
        [parameter(Mandatory=$True, Position=0, ValueFromPipeline=$True, ValueFromPipelineByPropertyName=$True)]
        [PsArmLoadBalancer] $loadBalancer,

        [parameter(Mandatory=$True)]
        [string] $Name,

        [parameter(Mandatory=$True)]
        [string] $SubnetId,

        [parameter(Mandatory=$False)]
        [string] $PublicIpAddressId,

        [parameter(Mandatory=$False)]
        [string] $PrivateIpAddress
    )

    Write-Verbose "Scripting Load Balancer FrontEndIpConfiguration $Name on $SubnetId"

    # assign all ipConfiguration settings
    $ipConfig = [PsArmIpConfig]::New()
    $ipConfig.name = "$Name"
    $ipConfig.properties = [PsArmIpConfigProperties]::New()

    if ($PrivateIpAddress -and $PrivateIpAddress -ne '') {
        $ipConfig.properties.privateIpAddress = $PrivateIpAddress
        $ipConfig.properties.privateIpAllocationMethod = 'Static'
    }

    # associate the PublicIp
    if ($PublicIpAddressId) {
        $ipConfig.properties.publicIpAddress = [PsArmId]::New()
        $ipConfig.properties.publicIpAddress.id = $PublicIpAddressId

        $nic.dependsOn += $PublicIpAddressId
    }

    $ipConfig.properties.subnet = [PsArmId]::New()
    $ipConfig.properties.subnet.id = $SubnetId

    # return the results
    $loadBalancer.properties.frontendIpConfigurations += $ipConfig
    return $loadBalancer
}


##########################################################################

Function Add-PsArmLoadBalancerBackendAddressPool
{
    [CmdletBinding()]

    Param (
        [parameter(Mandatory=$True, Position=0, ValueFromPipeline=$True, ValueFromPipelineByPropertyName=$True)]
        [PsArmLoadBalancer] $loadBalancer,

        [parameter(Mandatory=$True)]
        [string] $Name
    )

    # return the results
    $loadBalancer.properties.backendAddressPools += New-PsArmName -Name $Name
    return $loadBalancer
}

##########################################################################

Function Add-PsArmLoadBalancerProbe
{
    [CmdletBinding()]

    Param (
        [parameter(Mandatory=$True, Position=0, ValueFromPipeline=$True, ValueFromPipelineByPropertyName=$True)]
        [PsArmLoadBalancer] $loadBalancer,

        [parameter(Mandatory=$True)]
        [string] $Name,

        [parameter(Mandatory=$True)]
        [string] $Protocol,

        [parameter(Mandatory=$True)]
        [string] $Port,

        [parameter(Mandatory=$False)]
        [string] $IntervalInSeconds = 15,

        [parameter(Mandatory=$False)]
        [string] $TimeoutInSeconds = 31,

        [parameter(Mandatory=$True)]
        [string] $NumberOfProbes
    )

    $probe = [PsArmLoadBalancerProbe]::New()
    $probe.Name = $Name
    $probe.properties.protocol = $Protocol
    $probe.properties.port = $Port
    $probe.properties.intervalInSeconds = $IntervalInSeconds
    $probe.properties.timeoutInSeconds = $TimeoutInSeconds
    $probe.properties.numberOfProbes = $NumberOfProbes

    # return the results
    $loadBalancer.properties.probes += $probe
    return $loadBalancer

}

##########################################################################

Function Add-PsArmLoadBalancerLoadBalancingRule
{
    [CmdletBinding()]

    Param (
        [parameter(Mandatory=$True, Position=0, ValueFromPipeline=$True, ValueFromPipelineByPropertyName=$True)]
        [PsArmLoadBalancer] $loadBalancer,

        [parameter(Mandatory=$True)]
        [string] $Name,

        [parameter(Mandatory=$True)]
        [string] $FrontEndIpConfigurationName,

        [parameter(Mandatory=$True)]
        [string] $BackendAddressPoolName,

        [parameter(Mandatory=$True)]
        [string] $ProbeName,

        [parameter(Mandatory=$True)]
        [string] $Protocol,

        [parameter(Mandatory=$True)]
        [int] $FrontEndPort,

        [parameter(Mandatory=$True)]
        [int] $BackendPort,

        [parameter(Mandatory=$False)]
        [bool] $EnableFloatingIp = $false,

        [parameter(Mandatory=$False)]
        [int] $IdleTimeoutInMinutes = 10
    )

    $rule = [PsArmLoadBalancerLoadBalancingRule]::New()
    $rule.name = $Name
    $rule.properties.frontendIPConfiguration = New-PsArmid -ResourceId "[concat(resourceId('Microsoft.Network/loadBalancers', '$($loadBalancer.name)'), '/frontendIPConfigurations/$($FrontEndIpConfigurationName)')]"
    $rule.properties.backendAddressPool = New-PsArmId -ResourceId "[concat(resourceId('Microsoft.Network/loadBalancers', '$($loadBalancer.name)'), '/backendAddressPools/$($BackendAddressPoolName)')]"
    $rule.properties.probe = New-PsArmId -ResourceId "[concat(resourceId('Microsoft.Network/loadBalancers', '$($loadBalancer.name)'), '/probes/$($ProbeName)')]"
    $rule.properties.protocol = $Protocol
    $rule.properties.frontendPort = $FrontEndPort
    $rule.properties.backendPort = $BackendPort
    $rule.properties.enableFloatingIP = $EnableFloatingIp
    $rule.properties.idleTimeoutInMinutes = $IdleTimeoutInMinutes

    # return the results
    $loadBalancer.properties.loadbalancingRules += $rule
    return $loadBalancer
}


#######################################m################################

Function New-PsArmQuickVm
{
    [CmdletBinding()]

    Param(
        [parameter(Mandatory=$True)]
        [string] $VmName,

        [parameter(Mandatory=$False)]
        [string] $osType,

        [parameter(Mandatory=$True)]
        [string] $VNetName,

        [parameter(Mandatory=$True)]
        [ValidateNotNull()] #No value
        [array] $SubnetName,

        [parameter(Mandatory=$True)]
        [string] $VmSize,

        [parameter(Mandatory=$True)]
        [string] $StorageAccountResourceGroupName,

        [parameter(Mandatory=$True)]
        [string] $StorageAccountName,

        [parameter(Mandatory=$False)]
        [hashtable] $tags = @{"deploytype" = "PsArmQuickVM"},

        [parameter(Mandatory=$False)]
        [string] $VhdImageName,

        [Parameter(Mandatory=$False)]
        [string] $osDiskName = "$($VmName)_OsDisk",

        [Parameter(Mandatory=$False)]
        [array] $DataDiskStorageAccountName,

        [Parameter(Mandatory=$False)]
        [array] $DataDiskSize,

        [Parameter(Mandatory=$False)]
        [array] $StaticIPAddress,

        [Parameter(Mandatory=$False)]
        [bool] $CreatePublicIp,

        [Parameter(Mandatory=$False)]
        [string] $AdminUsername = "adminstrator",

        [Parameter(Mandatory=$False)]
        [string] $AdminPassword = "p@55w0rd",
        [Parameter(Mandatory=$False)]
        [string] $PlanName,

        [Parameter(Mandatory=$False)]
        [string] $Product,

        [Parameter(Mandatory=$False)]
        [string] $Publisher,

        [Parameter(Mandatory=$False)]
        [string] $Offer,

        [Parameter(Mandatory=$False)]
        [string] $Sku,

        [Parameter(Mandatory=$False)]
        [string] $Version = 'latest',

        [Parameter(Mandatory=$False)]
        [string] $AvailabilitySetName,

        [Parameter(Mandatory=$False)]
        [string] $CustomExtensionUri,

        [Parameter(Mandatory=$False)]
        [array] $NetworkSecurityGroupName,

        [Parameter(Mandatory=$False)]
        [array] $dependsOn
    )

    $resources = @()

    Write-Verbose "Scripting QuickVM $VmName"

    # get location from vNet
    $vNet = Get-AzureRmVirtualNetwork -ResourceGroupName $VNetName -Name $VNetName
    if (-not $vNet) {
        throw "Invalid VNetName $VnetName"
    }
    $location = $vNet.Location

    # ensure vhdimage exists
    # $imageStorageAccount = Get-AzureRmStorageAccount -ResourceGroupName $global:AzureStorageResourceGroupName -Name $global:AzureStorageAccountName -ErrorAction "Stop"

    # verify storage & vnet locations
    $storageAccount = Get-AzureRmStorageAccount -ResourceGroupName $StorageAccountResourceGroupName -Name $StorageAccountName -ErrorAction "Stop"
    if ($vNet.Location -ne $storageAccount.Location) {
        Write-Error "VirtualNetwork location and StorageAccount location do not match"
        return
    }

    # verify image info
    if ($Publisher) {
        # marketplace
        if ((-not $PlanName) -or (-not $Product) -or (-not $Offer) -or (-not $Sku)) {
            Write-Error 'PlanName, Product, Offer and Sku required when Publisher provided.'
            throw 1
        }

    } else {
        Write-Error "Custom image currently not supported"
        return

        # # custom image
        # if (-not $vhdImageName.EndsWith('.vhd')) {
        #     $vhdImageName = $vhdImageName + '.vhd'
        # }

        # # ensure that vhdimage exists in destination OS storage
        # if ($storageAccountName -ne $global:AzureStorageAccountName) {
        #     # verify the storage account has the image provided
        #     Write-Verbose "Copying VHD image"

        #     $sourceStorageKey = $(Get-AzureRmStorageAccountKey -ResourceGroupName $global:AzureStorageResourceGroupName -Name $global:AzureStorageAccountName).Value[0]
        #     $destStorageKey = $(Get-AzureRmStorageAccountKey -ResourceGroupName $StorageAccountResourceGroupName -Name $StorageAccountName).Value[0]

        #     $sourceStorageContext = New-AzureStorageContext -StorageAccountName $global:AzureStorageAccountName -StorageAccountKey $sourceStorageKey -ErrorAction Stop
        #     $destStorageContext   = New-AzureStorageContext -StorageAccountName $StorageAccountName -StorageAccountKey $destStorageKey -ErrorAction Stop


        #     # ensure vhdimages container exists
        #     $container = Get-AzureStorageContainer -Context $destStorageContext -Name 'vhdimages' -ErrorAction SilentlyContinue
        #     if (-not $container) {
        #         $container = New-AzureStorageContainer -Context $destStorageContext -Name 'vhdimages'
        #     }

        #     $blobCopy = Start-CopyAzureStorageBlob -Force `
        #         -Context $sourceStorageContext -SrcContainer "vhdimages" -SrcBlob $vhdImageName `
        #         -DestContext $destStorageContext -DestContainer "vhdimages" -DestBlob $vhdImageName `
        #         -ErrorAction "Stop"

        #     do {
        #         sleep 10
        #         $copyState = $blobCopy | Get-AzureStorageBlobCopyState
        #         $message = $CopyState.Source.AbsolutePath + " " + $CopyState.Status + " {0:N2}%" -f (($CopyState.BytesCopied/$CopyState.TotalBytes)*100)
        #         Write-Verbose $message
        #     } until ($copyState.Status -eq "Success")
        # }

    }

    # create Pip
    if ($CreatePublicIp) {
        $pipName = $vmName + "Pip0"
        $domainNameLabel = $VmName.ToLower()

        $resources += New-PsArmPublicIpAddress -Name $pipName -Location $location -DomainNameLabel $domainNameLabel -tags $tags
    }


    # get username/password
    # if (-not $AdminUsername) {
    #     $AdminUsername = $(Get-AzureKeyVaultSecret -VaultName "$global:AzureKeyVaultName" -Name "username" -ErrorAction "Stop").SecretValueText
    # }

    # if (-not $AdminPassword) {
    #     $AdminPassword = $(Get-AzureKeyVaultSecret -VaultName "$global:AzureKeyVaultName" -Name "password" -ErrorAction "Stop").SecretValueText
    # }

    # storageProfile
    $osDiskUri = '{0}vmdisks/{1}_osdisk.vhd' -f $storageAccount.PrimaryEndpoints.Blob.ToString(), $vmName


    # Create the VM
    $vm = New-PsArmVmConfig -VmName $VmName -VmSize $VmSize -tags $tags
    $vm = $vm | Set-PsArmVmOperatingSystem -ComputerName $VmName -AdminUserName $AdminUserName -AdminPassword $AdminPassword -ProvisionVmAgent

    if ($Publisher) {
        $vm.plan = [PsArmVmPlan]::New()
        $vm.plan.name = $Sku
        $vm.plan.product = $Product
        $vm.plan.publisher = $Publisher

        $vm = Set-PsArmVmSourceImage -VM $vm -Publisher $Publisher -Offer $Offer -Sku $Sku -Version 'latest'
        $vm = Set-PsArmVmOSDisk -VM $vm -Name $osDiskName -VhdUri $OsDiskUri -CreateOption 'FromImage'
    } else {
        $sourceImageUri = $($storageAccount.PrimaryEndpoints.Blob.ToString()) + "vhdimages/" + $vhdImageName
        $vm = Set-PsArmVmOSDisk -VM $vm -Name $osDiskName -VhdUri $OsDiskUri -SourceImageUri $sourceImageUri -CreateOption 'FromImage'
    }

    # create one or more Nics
    $i = 0
    foreach ($thisSubnetName in $SubnetName) {
        # get subnet Id
        $thisSubnetId = $($vnet.Subnets | Where-Object {$_.Name -eq $thisSubnetName}).Id
        if (-not $thisSubnetId) {
            Write-Error "Subnet $thisSubnetName not found as part of $($vnet.Name)"
            return
        }

        # get corresponding static Ip
        $thisIpAddress = $null
        if ($StaticIpAddress) {
            if ($i -le $StaticIpAddress.Count) {
                $thisIpAddress = $StaticIpAddress[$i]
            }
        }

        # get cooresponding Nsg
        $thisNsgId = $null
        if ($NetworkSecurityGroupName -and $NetworkSecurityGroupName[$i]) {
            $thisNsg = Find-AzureRmResource -ResourceType 'Microsoft.Network/networkSecurityGroups' -ResourceNameContains $NetworkSecurityGroupName[$i] | Where-Object {$_.Name -eq $NetworkSecurityGroupName[$i]}
            if ($thisNsg) {
                $thisNsgId = $thisNsg.ResourceId
            } else {
                Write-Verbose "Nsg $networkSecurityGroupName assumed to be in template"
                $thisNsgId = "[resourceId('Microsoft.Network/networkSecurityGroups', '$networkSecurityGroupName')]"
            }
        }

        # set publicIp if created
        $publicIpAddressId = $null
        if ($CreatePublicIp -and $i -eq 0) {
            # assume publicIpAddress is being created in this template
            $publicIpAddressId = "[resourceId('Microsoft.Network/publicIPAddresses', '$pipName')]"
        }

        # create the Nic
        $nicName = $vmName + "Nic" + $i.ToString()
        $nic = New-PsArmNetworkInterface -Name $nicName -Location $location -SubnetId $thisSubnetId -PrivateIpAddress $thisIpAddress -PublicIpAddressId $publicIpAddressId -NetworkSecurityGroupId $thisNsgId -tags $tags

        # add Nic to the resource
        $resources += $nic

        # add NIC to VM
        $vm = Add-PsArmVmNetworkInterface -VM $vm -Id "[resourceId('Microsoft.Network/networkInterfaces', '$($nic.Name)')]"

        $i++
    }

    # Specify the data disk
    if ($DataDiskSize) {
        for ($i=0; $i -lt $DataDiskSize.Count; $i++) {
            $dataVhdStorageAccountName = $DataDiskStorageAccountName[$i]
            $dataVhdDiskSize = $DataDiskSize[$i]
            $dataDiskName = "$($VmName)_dataDisk_$($i)"

            if (-not $dataVhdStorageAccountName) {
                $dataVhdStorageAccountName = $StorageAccountName
            }

            $dataVhdResource = Find-AzureRmResource -ResourceName $dataVhdStorageAccountName -ResourceType 'Microsoft.Storage/storageAccounts'

            if ($dataVhdResource) {
                $dataVhdStorageAccount = Get-AzureRmStorageAccount -ResourceGroupName $($dataVhdResource.ResourceGroupName) -Name $dataVhdStorageAccountName -ErrorAction "Stop"
                $endpoint = $dataVhdStorageAccount.PrimaryEndPoints.Blob.ToString()
            } else {
                Write-Error "$dataVhdStorageAccountName StorageAccount does not exist, please create and try again."
                return
                # storage not found, assume the storage must be created as part of the template
                # $parts = $storageAccountName.PrimaryEndPoint.Blob.Split('./')
                # $endpoint = $parts[0] + '//' +  $dataVhdStorageAccountName + '.' + $($parts[3..6] -join '.') + '/'

                # $vm = Add-PsArmVmDependsOn -VM $vm -Id "[resourceId('Microsoft.Storage/storageAccounts', '$dataVhdStorageAccountName')]"
            }
            $dataDiskVhdUri = '{0}vmdisks/{1}_datadisk_{2}.vhd' -f $endpoint, $vmName, $i

            $vm = Add-PsArmVmDataDisk -Vm $vm -Name $dataDiskName `
                    -VhdUri $dataDiskVhdUri `
                    -Lun $i `
                    -CreateOption 'Empty' `
                    -DiskSizeInGB $dataVhdDiskSize
        }
    }

    # set availability set
    if ($AvailabilitySetName) {
        $vm = Set-PsArmAvailabilitySet -VM $vm  `
            -Id "[resourceId('Microsoft.Compute/availabilitySets', '$AvailabilitySetName')]"
    }

    # add any dependsOn passed in
    if ($dependsOn -and $dependsOn.count -ne 0) {
        $vm = Add-PsArmVmDependsOn -VM $vm -Id $dependsOn
    }

    $resources += $vm

    # Specify custom extension script
    if ($CustomExtensionUri) {
        $uriParts = $CustomExtensionUri.Split('/')
        $uriStorageAccountName = $uriParts[2].Split('.')[0]
        $uriContainer = $uriParts[3]
        $uriBlobName = $uriParts[4..$($uriParts.Count-1)] -Join '/'

        $storage = Get-AzureRmResource | Where-object {$_.Name -eq $uriStorageAccountName -and $_.ResourceType -eq 'Microsoft.Storage/storageAccounts'}
        if (-not $storage) {
            Write-Error "Invaild CustomExtentionUri. $uriStorageAccount Storage account not found."
            return
        }

        $uriStorageAccountKey = $(Get-AzureRmStorageAccountKey -ResourceGroupName $($storage.ResourceGroupName) -Name $uriStorageAccountName).Value[0]

        $resources += New-PsArmVmCustomScriptExtension `
                        -VMName $vm.Name `
                        -CustomExtensionUri $CustomExtensionUri `
                        -StorageAccountName $uriStorageAccountName `
                        -StorageAccountKey $uriStorageAccountKey
    }

    # Deploy new VM
    return $resources
}
