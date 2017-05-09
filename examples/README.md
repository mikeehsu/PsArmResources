# PSArmResources Examples

- `FirstVirtual.ps1`: A PsArmResources implementation of tutorial,
[Create your first virtual network](https://docs.microsoft.com/en-us/azure/virtual-network/virtual-network-get-started-vnet-subnet). Running `./FirstVirtual.ps` when you've already authenticated with `Login-AzureRMAccount` should create a resource group, `MyRG` with a vnet, 2 subnets, and 2 VMs. You may need to change the name of the storage account to prevent namespace conflicts.
- `FirstVirtualDRY.ps1`: Identical functionality to `FirstVirtual.ps` but demonstrates use of a common VM creation function.
- `FirstVirtual.tests.ps`: Demonstrates that a specification of your resource group matches (or not) what will be created by `FirstVirtualDRY.ps`, or that it matches what is actually deployed in that resource group. Prior to creating anything in Azure, you can run: `Invoke-Pester -Tag Desired` and you should get output as shown below. After creating `MyRG` you can similarly tests with `Invoke-Pester -Tag Actual` and get similar output:
```
Describing MyRG
   Context Resource Group Total
    [+] should have 7 total resources 648ms
   Context Overall Group
    [+] should have 1 Microsoft.Network/virtualNetworks 130ms
    [+] should have 1 Microsoft.Network/publicIPAddresses 12ms
    [+] should have 2 Microsoft.Network/networkInterfaces 15ms
    [+] should have 1 Microsoft.Storage/storageAccounts 14ms
    [+] should have 2 Microsoft.Compute/virtualMachines 25ms
   Context VMs
    [+] desired should include VM named MyWebServer and sized Standard_DS1_V2 74ms
    [+] desired should include VM named MyDBServer and sized Standard_DS2_V2 25ms
   Context StorageAccounts
    [+] should True include storage account myrgdemostorage 91ms
    [+] should use replication LRS 35ms
   Context VNet
    [+] should include vNet myvnet 73ms
    [+] should use AddressPrefix <AddressPrefixes> 66ms
    [+] should have 2 subnets 30ms
Tests completed in 1.24s
Passed: 13 Failed: 0 Skipped: 0 Pending: 0
```
- `PsArmQuickVMExample`: Demonstrates creating a resource group with a single VM using the `New-PsArmQuickVM` function. Assumes you already have:
    - A vNet with Subnet
    - A storage account
- `VnetNsgPipGateway.ps1`: Vnet with Subnet, Network Security Group, PublicIP, and a Gateway
- `VnetStorageVmNic.ps1`: Another vnet plus VM complete example.

