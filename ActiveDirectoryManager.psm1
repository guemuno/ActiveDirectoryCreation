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

    [System.Collections.ArrayList]CreateUsersAD([string]$FilePath)
    {
        $results = [System.Collections.ArrayList]::new()
        $users = $this.GetUsersFromExcel($FilePath)
        foreach($user in $users)
        {
            $securePassword  =  ConvertTo-SecureString ("MyPassword" + $user.DateofBirth.ToString("yyyy-MM-dd") + "*") -Force -AsPlainText
            $existUser = Get-ADUser -Filter (" SamAccountName -eq '" + $user.UserName + "'")
            if (-not $existUser) {
                New-ADUser  -AccountPassword $securePassword  -Name ($user.LastName + " " + $user.Name)  -GivenName $user.LastName -Surname $user.Name     -ChangePasswordAtLogon  $true -Department $user.Department  -Enabled  $true -SamAccountName $user.UserName -Title $user.JobTitle
                $results.Add("the user " + $user.LastName + " " + $user.Name  +" has been added with the password: " + "MyPassword" + $user.DateofBirth.ToString("yyyy-MM-dd")+ "`n")
            }
            else {
                $results.Add("the user " + $user.LastName + " " + $user.Name  +" already exist`n")
            }
        }
        return $results
    }

    SetDefaultPolicies()
    {
        $policyName = "Initial policies"
        $currentPolicy = Get-GPO -all   | Where-Object {$_.DisplayName  -match $policyName }
        if(-not $currentPolicy)
        {
            $dc =Get-ADDomainController
            New-GPO -Name $policyName -Comment "Default client settings for PCs"  | New-GPLink -Target $dc.DefaultPartition
        }
        Set-GPRegistryValue -Name $policyName -Key "HKCU\Control Panel\\Desktop" -ValueName ScreenSaveTimeOut -Type DWord -Value 300
        Set-GPRegistryValue -Name $policyName -Key "HKCU\Software\Policies\Microsoft\Windows\Control Panel" -ValueName "ProhibitAccessToControlPanel" -Value 1 -Type DWORD
        Set-GPRegistryValue -Name $policyName -Key "HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" -ValueName "NoControlPanel" -Value 1 -Type DWORD
        Set-GPRegistryValue -Name $policyName -Key "HKCU\Software\Policies\Microsoft\Windows\RemovableStorageDevices" -ValueName "Deny_All" -Value 1 -Type DWORD
        
    }
}
