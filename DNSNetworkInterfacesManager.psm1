using module .\DNSNetworkInterface.psm1
class DNSNetworkInterfacesManager {
    
    DNSNetworkInterfaces() {
    }
    [System.Collections.ArrayList]GetDNSNetworkInterfaces(){
        
            $NetworkInterfaces =  Get-NetIPInterface -AddressFamily IPv4 -ConnectionState Connected
            $networkInterfacesList =  [System.Collections.ArrayList]::new()
            foreach ($NetworkInterface in $NetworkInterfaces )
            {
                $ipConfig = Get-NetIPAddress -InterfaceIndex  $NetworkInterface.ifIndex  -AddressFamily IPv4
                $description = Get-NetAdapter -InterfaceIndex  $NetworkInterface.ifIndex 
                [DNSNetworkInterface]$interface = [DNSNetworkInterface]::new(
                    $NetworkInterface.ifIndex,
                    $NetworkInterface.InterfaceAlias,
                    $ipConfig.IPAddress,
                    $description.InterfaceDescription
                )
                $networkInterfacesList.Add($interface)
            }
        return $networkInterfacesList
    }

    SetStaticIPDNS([string]$interfaceIndex){
        $interfaceIpConfiguration =  Get-NetIPConfiguration -InterfaceIndex $interfaceIndex 
        $interfaceDNSConfiguration = Get-DnsClientServerAddress -InterfaceIndex $interfaceIndex  -AddressFamily IPv4 
        Remove-NetRoute -InterfaceIndex  $interfaceIndex -AddressFamily IPv4 -Confirm:$false
        Remove-NetIPAddress -InterfaceIndex  $interfaceIndex  -AddressFamily IPv4  -Confirm:$false
        Set-DnsClientServerAddress -InterfaceIndex $interfaceIndex -ServerAddresses ($interfaceIpConfiguration.IPv4Address.IPAddress, $interfaceDNSConfiguration.ServerAddresses[0]) 
        New-NetIpAddress -InterfaceIndex $interfaceIndex  -IPAddress $interfaceIpConfiguration.IPv4Address.IPAddress -PrefixLength  $interfaceIpConfiguration.IPv4Address.PrefixLength -DefaultGateway $interfaceIpConfiguration.IPv4DefaultGateway.NextHop  -AddressFamily IPv4
    }
}

