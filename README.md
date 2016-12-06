# PsArmResources
Welcome to the PsArmResources (Powershell for ARM resources) repository.

The repository was built to help create ARM templates using Powershell instead of handcoding JSON. By using the strengths of Powershell this library provides advanced logic and use of complex datatypes, along with the capability of using the existing AzureRM modules to check the environment or retrieve data/conditions of your Azure subscription/resources as the templates are built.

This module tries to create a one-for-one replacement of similar AzureRM calls to create Azure resources, such as New-AzureRmVirtualNetworks, New-AzureRmNetworkInterface, New-AzureRmVm, etc.  Rather than directly creating the resources in Azure immediately, these functions create JSON resources and returns them, allowing you to add them to a template. The resulting template can then be deployed using New-AzureRmResourceGroupDeployment.

Example of a basic VirtualMachine deployment:

````
$template = New-PsArmTemplate 

$vm = New-PsAzureVmConfig -VMName $VmName -VMSize $VmSize |
        Set-AzureRmVMOperatingSystem -Windows -ComputerName $ComputerName -AdminUsername $AdminUsername -AdminPassword $AdminPassword |
        Add-AzureRmVMNetworkInterface -Id $nic.Id |
        Set-AzureRmVMOSDisk -Name $OSDiskName -VhdUri $OSDiskUri -SourceImageUri $SourceImageUri -Windows

Save-PsArmTemplate -template

New-AzureRmResourceGroupDeployment
````
> **Note**:   

## Contributing

