using module .\DNSNetworkInterface.psm1
using module .\DNSNetworkInterfacesManager.psm1
using module .\ActiveDirectoryManager.psm1
Import-Module ADDSDeployment

function Invoke-ActiveDirectoryCreation() {
        [DNSNetworkInterfacesManager]$ni = [DNSNetworkInterfacesManager]::new()
        [ActiveDirectoryManager]$activeDirecoryManager = [ActiveDirectoryManager]::new()
        $SelectedInterfaceIndex  = ""
        $canContinue = $false
        $serverName = $env:computername
        $SelectedNameOption  = Read-Host  "Prompt The name of the computer is "  $serverName  ", do you want to change it?"
        if($SelectedNameOption -eq "y")
        {
                $newNameServer = Read-Host  "Insert the new name(the computer will restart): "
                Rename-Computer -NewName $newNameServer
                Restart-Computer
        }
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
        $resultStaticIP = $ni.SetStaticIPDNS($SelectedInterfaceIndex)
        Write-Host($resultStaticIP)
        $activeDirecoryManager.InstallDomainServices();
        Write-Host("Domain Services Installed")
        $newDomainName = Read-Host  -Prompt  "Insert the new domain "
        Write-Host "After forest is installed the machine will reboot"
        $resultDomain = $activeDirecoryManager.SetUpDomainServices($newDomainName)
        Write-Host $resultDomain
        $filePath= Read-Host  -Prompt  "Insert path for the users file "
        $activeDirecoryManager.CreateUsersAD($filePath)

}


Invoke-ActiveDirectoryCreation