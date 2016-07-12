<#
    .SYNOPSIS
        Change UPN Suffix
    .DESCRIPTION
        Change UPN Suffix for all users located in an OU (and sub OU)
    .PARAMETER OldUPNSuffix
        Specify your current UPN Suffix, the one you want to change
        This parameter is mandatory
    .PARAMETER NewUPNSuffix
        Specify your new UPN Suffix
        This parameter is mandatory
    .PARAMETER UserOU
        Specify the OU where your users are located
        This parameter is mandatory
    .PARAMETER DC
        Specify the name of your domain controller
        This parameter is mandatory
    .EXAMPLE
        .\AD_Set-NewUPNSuffix.ps1 -OldUPNSuffix "contoso.local" -NewUPNSuffix "contoso.com" -UserOu "OU=Users,OU=Contoso,DC=contoso,DC=local" -DC "srv-ad.contoso.local"
        This script change the UPN Suffix of all users in the OU Users. The old UPN Suffix was contoso.local and the new UPN is contoso.com
    .NOTES
		This script must be used on a domain controller
        Author : Sylver SCHORGEN
        Blog : http://microsofttouch.fr/default/b/sylver
        Created : 18 feb. 2016
        @sylver_schorgen
#>


param (
    [Parameter(Mandatory=$true)]
    [string]$OldUPNSuffix,
    [Parameter(Mandatory=$true)]
    [string]$NewUPNSuffix,
    [Parameter(Mandatory=$true)]
    [string]$UserOu,
    [Parameter(Mandatory=$true)]
    [string]$DC
)

Import-LocalizedData -BindingVariable TextData -BaseDirectory (Join-Path -Path $PSScriptRoot -ChildPath Localized)

Write-Host
Write-Host $TextData.SetUpVariables -NoNewline

$ADModule = Get-Module ActiveDirectory

Try {
	if($ADModule -eq $null) {
		Import-Module ActiveDirectory -ErrorAction Stop
		Write-Host " $($TextData.OK)" -ForegroundColor Green
		Write-Host
	}
} catch {
	Write-Host " $($TextData.Error)" -ForegroundColor Red
	Write-Host
	Write-Host " $($TextData.ScriptStop)" -ForegroundColor Yellow
	Write-Host
	Exit
}

try {
    Write-Host $TextData.StartModifyUsers
    Write-Host
    
    Get-ADUser -SearchBase $UserOu -Filter * | ForEach-Object {
        Write-Host "$($TextData.ModifyUser) $($_.Name) ..." -NoNewline

        $NewUPN = $_.UserPrincipalName.Replace($OldUPNSuffix, $NewUPNSuffix)
        $_ | Set-ADUser -Server $DC -UserPrincipalName $NewUPN

        Write-Host " $($TextData.OK)" -ForegroundColor Green
    }
} catch {
    Write-Host " $($TextData.Error)" -ForegroundColor Red
}

Write-Host
