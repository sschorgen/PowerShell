<#
    .SYNOPSIS
        Show your hidden Exchange Online room mailboxes in the GAL
    .DESCRIPTION
        Show your hidden Exchange Online room mailboxes in the GAL so they can be used by your users
    .PARAMETER O365AdminLogin
        Specify an Office 365 Administrator
    .PARAMETER O365AdminPassword
        Specify the Office 365 Administrator password
    .EXAMPLE
        .\Show-O365RoomMailboxes.ps1 -O365AdminLogin "admin@mytenant.onmicrosoft.com" -O365AdminPassword "MYPASSWORD"
        This will show all your hidden room mailboxes in the GAL
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
Write-Host "Getting all resource mailboxes ... " -NoNewLine

Try {
	$Rooms = Get-Mailbox | Select Name,Alias,PrimarySmtpAddress,RecipientTypeDetails,HiddenFromAddressListsEnabled | Where {(($_.RecipientTypeDetails -eq 'EquipmentMailbox') -and ($_.HiddenFromAddressListsEnabled -eq $True))} -ErrorAction Stop
	Write-Host "Ok !" -ForeGroundColor Green
    Write-Host
} Catch {
	Write-Host "Error getting all resource mailboxes !" -ForeGroundColor Red
    Write-Host
	
	Remove-PSSession -Session $Session
    Exit	
}

Try {
	if($Rooms -ne $Null) {
		Write-Host
		Write-Host "Showing all your hidden resource mailboxes in GAL for all of your users ... " -NoNewLine
		
		foreach($Room in $Rooms) {
			Get-Mailbox $Room.PrimarySmtpAddress | Set-Mailbox -HiddenFromAddressListsEnabled $False
		}
		
		Write-Host "Ok !" -ForeGroundColor Green
		Write-Host
	}
} Catch {
	Write-Host "Error showing all resource mailboxes in GAL !" -ForeGroundColor Red
    Write-Host
	Exit
}

Remove-PSSession -Session $Session