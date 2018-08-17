<#
    .SYNOPSIS
        Configure email forwarding for a mailbox
    .DESCRIPTION
        Configure email forwarding for a mailbox. You must give the source and destination email addresses has parameters
    .PARAMETER sourceEmailAddress
        Sepcify your contact email address.
    .PARAMETER DestinationEmailAddress
        Specify your contact full name
    .PARAMETER KeepACopyAndForwad
        Keep a copy of each mail in the source mailbox and forward to the destination mailbox
    .EXAMPLE
        .\New-O365EmailForwardingRule.ps1 -sourceEmailAddress "john.doe@mail.com" -DestinationEmailAddress "jean.dupont@mail.com"
        .\New-O365EmailForwardingRule.ps1 -sourceEmailAddress "john.doe@mail.com" -DestinationEmailAddress "jean.dupont@mail.com" -KeepACopyAndForward $false
    .NOTES
        Author : Sylver SCHORGEN
        Blog : http://microsofttouch.fr/default/b/sylver
        Script version : 1.0
        Created : 18 aug. 2018
        Updated : 18 aug. 2018
        @sylver_schorgen
#>

Param(
    [Parameter(Mandatory=$true)]
    [string]$sourceEmailAddress,
    [Parameter(Mandatory=$true)]
    [string]$DestinationEmailAddress,
    [Parameter(Mandatory=$false)]
    [bool]$KeepACopyAndForward = $true
)
   
    # Prompt for Office 365 credentials
    $O365Credentials = Get-Credential
    
    Write-Output "`nConnecting to Exchange Online ..."
    
    # Connect to Exchange Online
	Try {		
		$Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://outlook.office365.com/powershell-liveid/ -Credential $O365Credentials -Authentication Basic -AllowRedirection -ErrorAction Stop
		Import-PSSession $Session | Out-Null
		
		Write-Output "`nConnection to Exchange Online Done !"
    }
    
    # If the connection fail, write an error. Probably because of a wrong credential
    Catch {
		Write-Error "`nError connecting to Exchange Online. Verify your credentials and try again !"
	}
    
    # Creating the mail forwarding rule
    try {
        $mailboxesWithForwarding = Get-Mailbox -ResultSize Unlimited | Where-Object {($_.ForwardingAddress -ne $Null) -or ($_.ForwardingsmtpAddress -ne $Null)} | Select-Object Name, ForwardingAddress, UserPrincipalName
        $alreadyExists = $false

        foreach ($mailbox in $mailboxesWithForwarding) {
            if ($mailbox.UserPrincipalName -eq $sourceEmailAddress) {
                $alreadyExists = $true
            }
        }

        # If the rule does not exist, we create it
        if ($alreadyExists -eq $false) {
            Write-Output "`nCreating email forwading rule for $sourceEmailAddress to $DestinationEmailAddress"
            
            # If you want to keep a copy in the source mailbox ($KeepInMailboxAndForward set to $true)
            if ($KeepACopyAndForward -eq $true) {
                Set-Mailbox $sourceEmailAddress -ForwardingAddress $DestinationEmailAddress -DeliverToMailboxAndForward $true
            }
            # If you want to keep a copy in the source mailbox ($KeepInMailboxAndForward set to $false)
            else {
                Set-Mailbox $sourceEmailAddress -ForwardingAddress $DestinationEmailAddress -DeliverToMailboxAndForward $false
            }

            Write-Output "Done creating email forwarding rule !"
        } 
        # If the rule does exist, we write a warning to the screen
        else {
            Write-Warning "A rule already exists for the mailbox $sourceEmailAddress !"
        }
    }

    # Catching error if there is an error in the contact creation
    catch {
        Write-Error "Error creating this email forwarding rule !"
    }

Get-PSSession | Remove-PSSession