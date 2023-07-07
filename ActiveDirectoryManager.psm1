Import-Module ADDSDeployment
class ActiveDirectoryManager {
    
    ActiveDirectoryManager(){}
    InstallDomainServices()
    {
        $statusAD = Get-WindowsFeature -Name AD-Domain-Services
        if(-not $statusAD.Installed)
        {
            Add-WindowsFeature AD-Domain-Services -IncludeManagementTools -IncludeAllSubFeature 
        }
    }

    [string]SetUpDomainServices([string]$DomainName)
    {
        $forest = Get-ADForest
        if( $forest.Domains) {
            return "There is a domain installed " + $forest.Domains
        }
        else {
        $domain = [uri]$DomainName
        $domainNetbiosName = $domain.Host -replace '^www\.' -replace '\..+$'

            Install-ADDSForest `
            -CreateDnsDelegation:$false `
            -DatabasePath "C:\Windows\NTDS" `
            -DomainMode "WinThreshold" `
            -DomainName $DomainName `
            -DomainNetbiosName $domainNetbiosName `
            -ForestMode "WinThreshold" `
            -InstallDns:$true `
            -LogPath "C:\Windows\NTDS" `
            -NoRebootOnCompletion:$false `
            -SysvolPath "C:\Windows\SYSVOL" `
            -Force:$true
            $forest = Get-ADForest
            return "The installed domain  is " + $forest.Domains
        }
    }
}
