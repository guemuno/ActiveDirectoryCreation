using module .\DNSNetworkInterface.psm1
using module .\DNSNetworkInterfacesManager.psm1
function Invoke-ActiveDirectoryCreation() {
    [DNSNetworkInterfacesManager]$ni = [DNSNetworkInterfacesManager]::new()
    $SelectedInterfaceIndex  = ""
    $canContinue = $false
        do{
            $interfaces = $ni.GetDNSNetworkInterfaces()
            $interfaces | Format-Table
            $SelectedInterfaceIndex  = Read-Host -Prompt "Select the index network interface to use"
            $interfaceSelected  = $interfaces.Where({$_.ifIndex -eq $SelectedInterfaceIndex})
            if(($null -ne $SelectedInterfaceIndex) -And ($null -ne $interfaceSelected) -And ($interfaceSelected.count -gt 0) )
            {
                $canContinue = $true
            }
        }while ($true -ne $canContinue)
        $ni.SetStaticIPDNS($SelectedInterfaceIndex)
}


Invoke-ActiveDirectoryCreation