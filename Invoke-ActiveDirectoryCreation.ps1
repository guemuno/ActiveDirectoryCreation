function Invoke-ActiveDirectoryCreation() {
    do{
        $NetworkInterfaces =  Get-NetIPInterface -AddressFamily IPv4 -ConnectionState Connected
        $Networkindexes = @()
        foreach ($NetworkInterface in $NetworkInterfaces )
        {
            $Networkindexes += $NetworkInterface.ifIndex
            $ipConfig = Get-NetIPAddress -InterfaceIndex  $NetworkInterface.ifIndex  -AddressFamily IPv4
            Write-Output "Id $($NetworkInterface.ifIndex) Alias  $($NetworkInterface.InterfaceAlias) ip $($ipConfig.IPAddress)"
        }
        $InterfaceIndex  = Read-Host -Prompt "Select the index network interface to use"
        $canContinue = $false
        $interfaceSelected  = $Networkindexes.Where({$_ -eq $InterfaceIndex})
        if(($null -ne $InterfaceIndex) -And ($null -ne $interfaceSelected) -And ($interfaceSelected.count -gt 0) )
        {
            $canContinue = $true
        }
    }while ($true -ne $canContinue)
}


Invoke-ActiveDirectoryCreation