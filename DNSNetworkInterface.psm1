class DNSNetworkInterface {
    [string]$ifIndex
    [string]$InterfaceAlias
    [string]$IPAddress
    [string]$InterfaceDescription
    DNSNetworkInterface(
        [string]$index,
        [string]$alias,
        [string]$IP,
        [string]$Description){
        $this.ifIndex = $index
        $this.InterfaceAlias = $alias
        $this.IPAddress = $IP
        $this.InterfaceDescription = $Description
    }
}