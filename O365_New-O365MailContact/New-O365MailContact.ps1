<#
    .SYNOPSIS
        Create a mail contact in your Exchange Online environment
    .DESCRIPTION
        Create a mail contact in your Exchange Online environment. We need to have his/her email address and name.
    .PARAMETER ContactEmailAddress
        Sepcify your contact email address.
    .PARAMETER UserFullName
        Specify your contact full name
    .PARAMETER HideFromGAL
        Specify if you want to hide the contact from your Exchange Online GAL. Is false by default
    .EXAMPLE
        .\New-O365MailContact.ps1 -ContactEmailAddress "john.doe@mail.com" -UserFullName "John DOE"
        .\New-O365MailContact.ps1 -ContactEmailAddress "john.doe@mail.com" -UserFullName "John DOE" -HideFromGAL $True
    .NOTES
        Author : Sylver SCHORGEN
        Blog : http://microsofttouch.fr/default/b/sylver
        Script version : 1.0
        Created : 17 aug. 2018
        Updated : 17 aug. 2018
        @sylver_schorgen
#>

Param(
    [Parameter(Mandatory=$true)]
    [string]$ContactEmailAddress,
    [Parameter(Mandatory=$true)]
    [string]$UserFullName,
    [Parameter(Mandatory=$false)]
    [bool]$HideFromGAL = $false
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
    
    # Verifying if the contact exists and adding it if it does not
    try {
        $alreadyExists = Get-MailContact -Identity $ContactEmailAddress -ErrorAction SilentlyContinue

        # If the contact is not already created, we create it
        if ($alreadyExists -eq $null) {
            Write-Output "`nAdding $UserFullName - $ContactEmailAddress to your contacts"
            New-MailContact -Name $UserFullName -DisplayName $UserFullName -ExternalEmailAddress $ContactEmailAddress | Out-Null
            Write-Output "Done creating $UserFullName - $ContactEmailAddress as a mail contact"
        } else {
            Write-Warning "$UserFullName - $ContactEmailAddress already exists !"
        }

        # Hiding contact from the GAL if you configured the parameter HideFromGAL with the value $True
        if ($HideFromGAL -eq $true) {
            Write-Output "`nHiding $UserFullName - $ContactEmailAddress from the GAL"
            Set-MailContact -Identity $ContactEmailAddress -HiddenFromAddressListsEnabled $true
            Write-Output "Done hiding $UserFullName - $ContactEmailAddress from the GAL"
        }
    }

    # Catching error if there is an error in the contact creation
    catch {
        Write-Error "Error creating $UserFullName - $ContactEmailAddress !"
    }

Get-PSSession | Remove-PSSession