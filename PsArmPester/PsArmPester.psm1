Set-StrictMode -Version Latest

Function Assert-PSArmGroupTotal {
    Param(
        [parameter(Mandatory=$True,Position=0)]
        [System.Object] $Target,

        [alias("Matches")]
        [parameter(Mandatory=$True,Position=1)]
        [string] $TestCases
    )
    Context "Resource Group Total" {
       It "should have $TestCases total resources" {
           $Target.resources.length | Should Be $TestCases
        }
    }
}

Function Assert-PsArmGroupSummary {
    Param(
        [parameter(Mandatory=$True,Position=0)]
        [System.Object] $Target,

        [alias("Matches")]
        [parameter(Mandatory=$True,Position=1)]
        [System.Object] $TestCases
    )
    Context "Overall Group" {
        It "should have <Expected> <Resource>" -TestCases $TestCases {
            param($Resource, $Expected)
            $Objects =  @($target.resources | where {$_.type -Eq $Resource})
            $Objects.length | Should be $Expected
        }
    } 
}

Function Assert-PsArmVM {
    Param(
        [parameter(Mandatory=$True,Position=0)]
        [System.Object] $Target,

        [alias("Matches")]
        [parameter(Mandatory=$True,Position=1)]
        [System.Object] $TestCases
    )
    Context "VMs" {
        $VMs = $target.resources | where {$_.type -eq 'Microsoft.Compute/virtualMachines'}
        It "desired should include VM named <Name> and sized <VmSize>" -TestCases $TestCases {
            param($Name, $VmSize)
            $normalizedName = $Name.Replace('-','_')
            $VM = $VMs | 
                where {$_.name -Match $Name -or $_.name -Match $normalizedName }
            $VM.properties.hardwareProfile.vmSize | Should be $VmSize
        }
    }
}

Function Assert-PsArmStorage {
    Param(
        [parameter(Mandatory=$True,Position=0)]
        [System.Object] $Target,

        [alias("Matches")]
        [parameter(Mandatory=$True,Position=1)]
        [System.Object] $TestCases
    )
    Context "StorageAccounts" {
        $StorageAccounts = $target.resources | where {$_.type -Match 'storageAccounts'}
        It  "should <State> include storage account <Name>" -TestCases $TestCases {
            param($Name, $State)
            $StorageAccount = $StorageAccounts | where {$_.name -Match $Name}
            if ($State) {
                $StorageAccount | Should Not BeNullOrEmpty
            } else {
                $StorageAccount | Should BeNullOrEmpty
            }
        }

        It "should use replication <Replication>" -TestCases $TestCases {
            param($Name, $Replication)
            $StorageAccounts = 
                $target.resources | where {$_.type -Match 'storageAccounts'}
            $StorageAccount = $StorageAccounts | where {$_.name -Match $Name}
            $StorageAccount.sku.name | Should Match $Replication
        }
    }
}

Function Assert-PsArmNetworkSecurityGroup {
    Param(
        [parameter(Mandatory=$True,Position=0)]
        [System.Object] $Target,

        [alias("Matches")]
        [parameter(Mandatory=$True,Position=1)]
        [System.Object] $TestCases
    )
    Context "NetworkSecurityGroup" {
        $NSGs = @($target.resources | 
            where {$_.type -Eq 'Microsoft.Network/networkSecurityGroups'})
        It  "should include networkSecurityGroup <Name>" -TestCases $TestCases {
            param($Name)
            @($NSGs | where {$_.name -Match $Name}).length | Should Be 1
        }

        It  "networkSecurityGroup <Name> should have <SecurityRuleCount> rules" -TestCases $TestCases {
            param($Name,$SecurityRuleCount)
            $NSG = $NSGs | where {$_.name -Match $Name} 
            $NSG.properties.securityRules.count | Should Be $SecurityRuleCount
        }
    }
}

Function Assert-PsArmVNet {
    Param(
        [parameter(Mandatory=$True,Position=0)]
        [System.Object] $Target,

        [alias("Matches")]
        [parameter(Mandatory=$True,Position=1)]
        [System.Object] $TestCases
    )
    Context "VNet" {
        $VNets = @($target.resources | 
            where {$_.type -Eq 'Microsoft.Network/virtualNetworks'})
        It  "should include vNet <Name>" -TestCases $TestCases {
            param($Name)
            @($VNets | where {$_.name -Match $Name}).length | Should Be 1
        }
        It "should use AddressPrefix <AddressPrefixes>" -TestCases $TestCases {
            param($Name, $AddressPrefixes)
            $VNet = $VNets | where {$_.name -Match $Name}
            $Vnet.properties.addressspace.addressPrefixes |
                Should Be $AddressPrefixes
        }
        It "should have <SubnetCount> subnets" -TestCases $TestCases {
            param($Name, $SubnetCount)
            $VNet = $VNets | where {$_.name -Match $Name}
            $Vnet.properties.subnets.count |
                Should Be $SubnetCount
        }
    }
}

Function Assert-PsArmRouteTable {
    Param(
        [parameter(Mandatory=$True,Position=0)]
        [System.Object] $Target,

        [alias("Matches")]
        [parameter(Mandatory=$True,Position=1)]
        [System.Object] $TestCases
    )
    Context "RouteTables" {
        $RouteTables = @($target.resources | 
            where {$_.type -Eq 'Microsoft.Network/routeTables'})
        It  "should include routeTable <Name>" -TestCases $TestCases {
            param($Name)
            @($RouteTables| where {$_.name -Match $Name}).length | Should Be 1
        }
        It "should have <RouteCount> routes" -TestCases $TestCases {
            param($Name, $RouteCount)
            $RouteTable = $RouteTables | where {$_.name -Match $Name}
            $RouteTable.properties.routes.count |
                Should Be $RouteCount
        }
    }
}

# Problem: $actual for DevVnetVA doesn't include the VNet peering information
#   Confirmed by ` $actual.resources[3].properties |ConvertTo-Json`
# and by reviewing the JSON emitted not containing string 'Peer'
#
# Solution: Ignore the problem and accept that we won't be able to model
#  everything with tests at this point
#
# Discussion Points:
# 1. Export-AzureRMtarget is incomplete, and doesn't export VNet peerings. This is an API limitation
# 2. The vNet Peerings can be seen with say:
#      PS> $a = Get-AzureRMResource -ResourceGroupName 'DevVnetVA' -ResourceType 'Microsoft.Network/virtualNetworks' -ExpandProperties
#      PS> $a.Properties.virtualNetworkPeerings.properties
#    and they's appears as properties of a property
# 3. Directy querying the API for all resources with properties doesn't work. See https://github.com/Azure/azure-powershell/issues/2494
#    for Invoke-RestMethod with Azure, but the `resources` endpoint doesn't actually expand the list
# 4. VNetPeering is weird, they are modelled not as properties of a Vnet, but as resources associated with a Vnet.
#    See https://github.com/Azure/azure-quickstart-templates/blob/master/201-vnet-to-vnet-peering/azuredeploy.json#L44-L65


Function Get-ActualResourceGroup([string] $ResourceGroupName) {
    $DeploymentName = $ResourceGroupName + $(get-date -f yyyyMMddHHmmss)
    $actualFile = $env:TEMP + '\actual-'+ $deploymentName + '.json'
    Write-Verbose "Saving actual Azure state to $actualFile"
    $result = Export-AzureRmResourceGroup -ResourceGroupName $ResourceGroupName -IncludeParameterDefaultValue -Path $actualFile
    Get-Content $actualFile | ConvertFrom-Json
}

Function Get-PsArmPesterDesiredResourceGroup([string] $ResourceGroupName, [string] $DeployScript) {
    if (Test-Path $DeployScript) {
        $DeploymentName = $ResourceGroupName + $(get-date -f yyyyMMddHHmmss)
        $desiredFile = $env:TEMP + '\desired-'+ $deploymentName + '.json'
        Write-Verbose "Save desired Azure state from $DeployScript to $desiredFile"
        Invoke-Expression "$DeployScript -Path $desiredFile"
        Get-Content $desiredFile | ConvertFrom-Json
    } else {
        Write-Error "Can't find path $DeployScript"
    }
}

Function Get-PsArmPesterResourceGroup {
    [CmdletBinding()]
    Param(
        [parameter(Mandatory=$True,ParameterSetName = "Desired")]
        [switch] $Desired,
        
        [parameter(Mandatory=$True,ParameterSetName = "Actual")]
        [switch] $Actual,

        [alias("RG")]
        [parameter(Mandatory=$True)]
        [string] $ResourceGroupName,

        [parameter(Mandatory=$True, ParameterSetName = "Desired")]
        [string] $DeployScript
    )

    if ($Desired) {
        if (Test-Path $DeployScript) {
            $DeploymentName = $ResourceGroupName + $(get-date -f yyyyMMddHHmmss)
            $desiredFile = $env:TEMP + '\desired-'+ $deploymentName + '.json'
            Write-Verbose "Save desired Azure state from $DeployScript to $desiredFile"
            Invoke-Expression "$DeployScript -Path $desiredFile"
            Get-Content $desiredFile | ConvertFrom-Json
        } else {
            Write-Error "Can't find path $DeployScript"
        }
    }
    if ($Actual) {
        $DeploymentName = $ResourceGroupName + $(get-date -f yyyyMMddHHmmss)
        $actualFile = $env:TEMP + '\actual-'+ $deploymentName + '.json'
        Write-Verbose "Saving actual Azure state to $actualFile"
        $result = Export-AzureRmResourceGroup -ResourceGroupName $ResourceGroupName -IncludeParameterDefaultValue -Path $actualFile
        Get-Content $actualFile | ConvertFrom-Json
    }
}
