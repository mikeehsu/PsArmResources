# PsArmResources
Welcome to the PsArmResources (Powershell for ARM resources) repository.

The repository was built to help create ARM templates using Powershell instead of hand-coding JSON. By using the strengths of Powershell, this library allows the use of advanced logic/branching and use of complex datatypes. Additionally, you able able to use the full capability of existing AzureRM modules to interrogate the environment and retrieve data/conditions of your Azure subscription/resources as the templates are being built.

This module tries to create a one-for-one replacement of similar AzureRM calls to create Azure resources, such as New-AzureRmVirtualNetworks, New-AzureRmNetworkInterface, New-AzureRmVm, etc.  Rather than directly creating the resources in Azure immediately, these functions creates Powershell objects and returns them, allowing you to add them to a larger template object, which mimics the Azure ARM JSON data schema. The resulting template object can then be rendered as JSON to a file (Save-PsArmTemplate) and deployed using the standard Azure ARM deployment (New-AzureRmResourceGroupDeployment).

Example of a basic VirtualMachine deployment:

````
Import-Module "PsArmResources" 

$template = New-PsArmTemplate 

$template.resources += `
    New-PsArmVMConfig -VMName $VMName -VMSize $VMSize |
        Set-PsArmVMOperatingSystem -Windows -ComputerName $ComputerName -AdminUserName $UserName -AdminPassword $Password -ProvisionVMAgent -EnableAutoUpdate |
        Set-PsArmVMSourceImage -Publisher MicrosoftWindowsServer -Offer WindowsServer -Sku 2012-R2-Datacenter -Version "latest" |
        Add-PsArmVMNetworkInterface -Id $InterfaceId |
        Set-PsArmVMOSDisk -Name $OSDiskName -CreateOption FromImage

Save-PsArmTemplate -Template $Template -TemplateFile $TemplateFile

New-AzureRmResourceGroup -Name $ResourceGroupName -Location $Location
New-AzureRmResourceGroupDeployment -Name $DeploymentName -ResourceGroupName $ResourceGroupName -TemplateFile $TemplateFile

````

> **Note**: For more examples see the ./examples directory


## Prerequisites and Installation

Requires Powershell `AzureRM` module.

Install:  Clone this repo, then add repository path to `$env:PSModulePath` with:

```ps1
$env:PSMODULEPATH += ";$HOME/path/to/PsArmResources"
Import-Module PsArmResources
```

Then testing with `New-PsArmTemplate` should look like this:
```
PS> \Projects\PsArmResources\examples> New-PsArmTemplate | ConvertTo-Json
{
    "schema":  "https://schema.management.azure.com/schemas/2015-01-01/deploymentTemplate.json#",
    "contentVersion":  "1.0.0.0",
    "resources":  [

                  ]
}
```


## Public domain

This project is in the worldwide [public domain](LICENSE.md). As stated in [CONTRIBUTING](CONTRIBUTING.md):

> To the extent possible under law, the author(s) have dedicated all copyright and related and neighboring rights to this software to the public domain worldwide through the [CC0 1.0 Universal public domain dedication](https://creativecommons.org/publicdomain/zero/1.0/).
> 
> All contributions to this project will be released under the CC0 dedication. By submitting a pull request, you are agreeing to comply with this waiver of copyright interest.

## Contributing

Mike Hsu
