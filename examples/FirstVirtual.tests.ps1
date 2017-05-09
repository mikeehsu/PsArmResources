<#   
Invoke-Pester -Test MyRG
#>

Import-Module "PsArmPester" -Force

$ResourceGroupName = 'MyRG'
$DeployScriptName  = 'FirstVirtualDRY.ps1'
# next line finds the deploy script relative to this test script:
$DeployScript = Join-Path ($PSCommandPath | Split-Path -Parent) $DeployScriptName

# Set up test cases
$ResourceTotalTestCase = 7
$ResourceSummaryTestCases = @( 
    @{
        Resource = "Microsoft.Network/virtualNetworks"
        Expected = 1
    },

    @{
        Resource = "Microsoft.Network/publicIPAddresses"
        Expected = 1
    },

    @{
        Resource = "Microsoft.Network/networkInterfaces"
        Expected = 2
    },
    @{
        Resource = "Microsoft.Storage/storageAccounts"
        Expected = 1
    },
    @{
        Resource = 'Microsoft.Compute/virtualMachines'
        Expected = 2
    }
) 

$VMTestCases = @(
    @{
        Name = 'MyWebServer'
        VmSize = 'Standard_DS1_V2'
    },
    @{
        Name = 'MyDBServer'
        VmSize = 'Standard_DS2_V2'
    }
) 

$StorageCases = @(
    @{
        Name = 'myrgdemostorage'
        State = $true
        Replication = 'LRS'
    }
)

$vNetCases = @(
    @{
        Name = 'myvnet'
        SubnetCount = 2
        AddressPrefix = '10.0.0.0/16'
    }
)

Describe $ResourceGroupName -Tag Actual {
    #$target = Get-ActualResourceGroup $ResourceGroupName
    $target = Get-PsArmPesterResourceGroup -Actual -RG $ResourceGroupName
    Assert-PSArmGroupTotal $target -Matches $ResourceTotalTestCase
    Assert-PSArmGroupSummary $target -Matches $ResourceSummaryTestCases
    Assert-PSArmVM $target -Matches $VMTestCases
    Assert-PSArmStorage $target -Matches $StorageCases
    Assert-PSArmVnet $target -Matches $vNetCases
}

Describe $ResourceGroupName -Tag Desired  {
    $target = Get-PsArmPesterResourceGroup -Desired -RG $ResourceGroupName -Deploy $DeployScript
    Assert-PSArmGroupTotal $target -Matches $ResourceTotalTestCase
    Assert-PSArmGroupSummary $target -Matches $ResourceSummaryTestCases
    Assert-PSArmVM $target -Matches $VMTestCases
    Assert-PSArmStorage $target -Matches $StorageCases
    Assert-PSArmVnet $target -Matches $vNetCases
}
