using module .\DNSNetworkInterface.psm1
class DNSNetworkInterfaces {
    
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
        $interface =  Get-NetIPConfiguration -InterfaceIndex $interfaceIndex 
        Get-NetIpAddress -InterfaceIndex $interface.InterfaceIndex  | New-NetIpAddress  IpAddress $interface.IPv4Address -PrefixLength 24 -DefaultGateway 192.168.1.1
    }
}