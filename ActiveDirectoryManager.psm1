using module .\UserActiveDirectory.psm1
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
        try{
        $forest = Get-ADForest
        if( $forest.Domains) {
                return "There is a domain installed " + $forest.Domains
            }
        }
        catch {  }
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
            Restart-Computer
            return ""
    }

    [System.Collections.ArrayList]GetUsersFromExcel([string]$FilePath)
    {
        $modules = Get-Module -Name ImportExcel -ListAvailable
        if(-not $modules.Name)
        {
            Install-Module ImportExcel -Force 
        }
        Import-Module ImportExcel
        $Sheet = Import-Excel -Path 'C:\Users\Administrator\Desktop\personal1.xlsx' 

        $users = [System.Collections.ArrayList]::new()
        foreach ($row in $Sheet)
        {
             $user =[UserActiveDirectory]::new($row.LastName,$row.Name,$row.JobTitle,$row.Department,$row.DateofBirth)
             $users.Add($user)
        }
        return  $users
    }

    CreateUsersAD([string]$FilePath)
    {
        $users = $this.GetUsersFromExcel($FilePath)
        foreach($user in $users)
        {
            $securePassword  =  ConvertTo-SecureString ("MyPassword" + $user.DateofBirth.ToString("yyyy-MM-dd") + "*") -Force -AsPlainText
            $existUser = Get-ADUser -Filter (" SamAccountName -eq '" + $user.UserName + "'")
            if (-not $existUser) {
                New-ADUser  -AccountPassword $securePassword  -Name ($user.LastName + " " + $user.Name)  -GivenName $user.LastName -Surname $user.Name     -ChangePasswordAtLogon  $true -Department $user.Department  -Enabled  $true -SamAccountName $user.UserName -Title $user.JobTitle
            }
        }
    }
}
