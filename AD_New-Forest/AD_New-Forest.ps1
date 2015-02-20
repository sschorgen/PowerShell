<#
    .SYNOPSIS
        Create a new Active Directory Forest
    .DESCRIPTION
        Create a new Active Directory Forest
    .PARAMETER DomainName
        Specify the domain name you want to give to your domain
    .PARAMETER NetbiosName
        Specify your domain netbios name
    .PARAMETER NTDSPath
        Specify your NTDS database Path
    .PARAMETER DomainMode
        Specify your domain level
        The domain level could be : Win2012R2 (default), Win2012, Win2008R2, Win2008 or Win2003
    .PARAMETER ForestMode
        Specify your forest level
        The forest level could be : Win2012R2 (default), Win2012, Win2008R2, Win2008 or Win2003
    .PARAMETER InstallDNS
        Specify if you want to add the DNS role
    .PARAMETER LogPath
        Specify your log path
    .PARAMETER NoRebootOnCompletion
        Specify $true if you don't want to reboot or $false if you want to reboot after completion
    .PARAMETER SysvolPath
        Specify your Sysvol path
    .PARAMETER CreateDnsDelegation
        Specify $true if you want to reference the new DNS server your are creating.
        This option must be true if you are using an existing DNS Server Infrastructure.
    .PARAMETER SafeModePassword
        Specify the administrator password for Directory Services Restore Mode (DRSM)
    .EXAMPLE
        .\AD_New-Forest.ps1 -domainName "demo.lan" -netbiosName "DEMO" -domainMode "Win2012R2" -ForestMode "Win2012R2" -safeModePassword "P@$$w0rd" -installDNS $true -NTDSPath "C:\Windows\NTDS" -LogPath "C:\Windows\NTDS"
        This will create a new forest with a 2012R2 domain mode and a 2012R2 forest mode
    .NOTES
        Author : Sylver SCHORGEN
        Blog : http://microsofttouch.fr/default/b/sylver
        Created : 02 feb. 2015
        @sylver_schorgen
#>


Param(
    [Parameter(Mandatory=$true)]
    [string]$DomainName,
    [Parameter(Mandatory=$true)]
    [string]$NetbiosName,
    [Parameter(Mandatory=$false)]
    [string]$NTDSPath = "C:\Windows\NTDS",
    [Parameter(Mandatory=$false)]
    [string]$DomainMode ="Win2012R2",
    [Parameter(Mandatory=$false)]
    [string]$ForestMode ="Win2012R2",
    [Parameter(Mandatory=$false)]
    [bool]$InstallDNS = $true,
    [Parameter(Mandatory=$false)]
    [string]$LogPath = "C:\Windows\NTDS",
    [Parameter(Mandatory=$false)]
    [bool]$NoRebootOnCompletion = $false,
    [Parameter(Mandatory=$false)]
    [string]$SysvolPath = "C:\Windows\SYSVOL",
    [Parameter(Mandatory=$false)]
    [bool]$CreateDnsDelegation = $false,
    [Parameter(Mandatory=$true)]
    [string]$SafeModePassword
)

try {
    Write-Host
    Write-Host
    Write-Host "Setting up initial variables ... " -NoNewLine

    $adFeatureInstalled = Get-WindowsFeature | where {$_.Name -eq "AD-Domain-Services"}
    $dnsFeatureInstalled = Get-WindowsFeature | where {$_.Name -eq "DNS"}
    $gpmcFeatureInstalled = Get-WindowsFeature | where {$_.Name -eq "GPMC"}
    $securePassword = ConvertTo-SecureString $SafeModePassword -AsPlaintext -Force

    Write-Host " Done !" -ForegroundColor Green
    Write-Host

    if ($adFeatureInstalled) {
        Write-Host "AD-Domain-Services feature already installed ... " -NoNewLine
        Write-Host " OK !" -ForegroundColor Green
        Write-Host
    }
    else {
        Write-Host "Installing AD-Domain-Services feature ... " -NoNewLine

        Add-WindowsFeature -Name "ad-domain-services" -IncludeAllSubFeature -IncludeManagementTools
        
        Write-Host " OK !" -ForegroundColor Green
        Write-Host
    }
    if ($dnsFeatureInstalled) {
        Write-Host "DNS feature already installed ... " -NoNewLine
        Write-Host " OK !" -ForegroundColor Green
        Write-Host
    }
    else {
        Write-Host "Installing DNS feature ... " -NoNewLine

        Add-WindowsFeature -Name "dns" -IncludeAllSubFeature -IncludeManagementTools
        
        Write-Host " OK !" -ForegroundColor Green
        Write-Host
    }
    if ($gpmcFeatureInstalled) {
        Write-Host "GPMC feature already installed ... " -NoNewLine
        Write-Host " OK !" -ForegroundColor Green
        Write-Host
    }
    else {
        Write-Host "Installing GPMC feature ... " -NoNewLine

        Add-WindowsFeature -Name "GPMC" -IncludeAllSubFeature -IncludeManagementTools
        
        Write-Host " OK !" -ForegroundColor Green
        Write-Host
    }

    Write-Host "Importing module Active Directory Domain Services ... " -NoNewLine
    
    Import-Module ADDSDeployment 

    Write-Host " Done !" -ForegroundColor Green
    Write-Host

    Write-Host "Installing new Active Directory Forest ... " -NoNewLine

    $forest = Install-ADDSForest -CreateDnsDelegation:$CreateDnsDelegation `
    -DomainName $DomainName `
    -DatabasePath $NTDSPath  `
    -DomainMode $DomainMode  `
    -DomainNetbiosName $NetbiosName  `
    -ForestMode $ForestMode  `
    -InstallDNS:$InstallDNS  `
    -LogPath $LogPath  `
    -NoRebootOnCompletion:$NoRebootOnCompletion  `
    -SysvolPath $SysvolPath  `
    -SafeModeAdministratorPassword $securePassword  `
    -Force:$true

    Write-Host " Done !" -ForegroundColor Green
    Write-Host

    Write-Host "Restarting computer ... " -NoNewLine

}
catch {
    Write-Host $_.Exception.Message -ForegroundColor Red
    Write-Host
}