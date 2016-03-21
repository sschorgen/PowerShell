Function Connect-ExchangeOnline {
	
	<#
    .SYNOPSIS
        Connect to your Exchange Online tenant
    .DESCRIPTION
        Connect to your Exchange Online tenant
    .PARAMETER O365AdminLogin
        Specify an Office 365 Administrator
    .PARAMETER O365AdminPassword
        Specify the Office 365 Administrator password
    .EXAMPLE
        .\Connect-ExchangeOnline.ps1 -O365AdminLogin "admin@mytenant.onmicrosoft.com" -O365AdminPassword "MYPASSWORD"
        This will connect you to your Exchange Online Tenant and load the Exchange Online Cmdlets
    .NOTES
        Author : Sylver SCHORGEN
        Blog : http://microsofttouch.fr/default/b/sylver
        Created : 21 mar. 2016
        Twitter : @sylver_schorgen
#>
	
	param (
		[Parameter(Mandatory=$true)]
		[string]$O365AdminLogin,
		[Parameter(Mandatory=$true)]
		[string]$O365AdminPassword
	)
	
	Write-Host
	Write-Host
	Write-Host "Connecting to Exchange Online ... " -NoNewLine
	
	Try {
		$O365SecureAdminPassword = ConvertTo-SecureString -AsPlainText $O365AdminPassword -Force
		$UserCredential  = New-Object System.Management.Automation.PSCredential ($O365AdminLogin,$O365SecureAdminPassword)
		
		$Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://outlook.office365.com/powershell-liveid/ -Credential $UserCredential -Authentication Basic -AllowRedirection -ErrorAction Stop
		Import-PSSession $Session
		
		Write-Host " DONE ! " -ForegroundColor Green
	} Catch {
		Write-Host " ERROR ! " -ForegroundColor Red
	}
	
}