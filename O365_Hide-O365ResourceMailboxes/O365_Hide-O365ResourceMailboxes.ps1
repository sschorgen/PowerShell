<#
    .SYNOPSIS
        Hide your Exchange Online equipment mailboxes from the GAL
    .DESCRIPTION
        Hide your Exchange Online equipment mailboxes from the GAL so they can't be used by your users
    .PARAMETER O365AdminLogin
        Specify an Office 365 Administrator
    .PARAMETER O365AdminPassword
        Specify the Office 365 Administrator password
    .EXAMPLE
        .\O365_Hide-O365EquipmentMailboxes.ps1 -O365AdminLogin "admin@mytenant.onmicrosoft.com" -O365AdminPassword "MYPASSWORD"
        This will hide all your equipment mailboxes from the GAL
    .NOTES
        Author : Sylver SCHORGEN
        Blog : http://microsofttouch.fr/default/b/sylver
        Created : 17 mar. 2016
        Twitter : @sylver_schorgen
#>

Param(
    [Parameter(Mandatory=$true)]
    [string]$O365AdminLogin,
    [Parameter(Mandatory=$true)]
    [string]$O365AdminPassword
)

# Setting up variables required for the script
Write-Host
Write-Host
Write-Host "Setting up initial variables ... " -NoNewLine

$O365SecureAdminPassword = ConvertTo-SecureString -AsPlainText $O365AdminPassword -Force
$Cred  = New-Object System.Management.Automation.PSCredential ($O365AdminLogin,$O365SecureAdminPassword)

Write-Host "Ok !" -ForeGroundColor Green
Write-Host
Write-Host
Write-Host "Connecting to Exchange Online ... " -NoNewLine

Try {
    # Connect to Exchange Online with a PowerShell Session
    $Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://outlook.office365.com/powershell-liveid/ -Credential $Cred -Authentication Basic –AllowRedirection -ErrorAction Stop
    Import-PSSession $Session -AllowClobber

    Write-Host "Ok !" -ForeGroundColor Green
    Write-Host
} Catch {
    Write-Host "Error connecting to Exchange Online !" -ForeGroundColor Red
    Write-Host
    Exit
}

Write-Host
Write-Host "Getting all equipment mailboxes ... " -NoNewLine

Try {
	$Equipments = Get-Mailbox | Select Name,Alias,PrimarySmtpAddress,RecipientTypeDetails | Where {$_.RecipientTypeDetails -eq 'EquipmentMailbox'} -ErrorAction Stop
	Write-Host "Ok !" -ForeGroundColor Green
    Write-Host
} Catch {
	Write-Host "Error getting all equipment mailboxes !" -ForeGroundColor Red
    Write-Host
	
	Remove-PSSession -Session $Session
    Exit	
}

Try {
	if($Equipments -ne $Null) {
		Write-Host
		Write-Host "Hiding all equipment mailboxes from GAL ... " -NoNewLine
		
		foreach($Equipment in $Equipments) {
			Get-Mailbox $Equipment.PrimarySmtpAddress | Set-Mailbox -HiddenFromAddressListsEnabled $True
		}
		
		Write-Host "Ok !" -ForeGroundColor Green
		Write-Host
	}
} Catch {
	Write-Host "Error hiding all equipment mailboxes from GAL !" -ForeGroundColor Red
    Write-Host
	Exit
}

Remove-PSSession -Session $Session