<#
    .SYNOPSIS
        Add a user to a distribution group
    .DESCRIPTION
        Add a user to a distribution group. We need to have his/her email address
    .PARAMETER DistributionGroupName
        Sepcify your distribution group name.
    .PARAMETER UserIdentity
        Specify user email address
    .EXAMPLE
        .\Add-UserToO365DistributionGroup.ps1 -DistributionGoupName "Marketing Team" -Member "john.doe@mail.com"
    .NOTES
        Author : Sylver SCHORGEN
        Blog : http://microsofttouch.fr/default/b/sylver
        Created : 17 aug. 2018
        Updated : 18 dec. 2018
        @sylver_schorgen
#>

Param(
    [Parameter(Mandatory=$true)]
    [string]$DistributionGroupName,
    [Parameter(Mandatory=$true)]
    [string]$UserIdentity
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
    
    # Adding user to the distribution group
    try {
        Write-Output "`nAdding $UserIdentity to $DistributionGroupName distribution group"
        $DLMembers = Get-DistributionGroupMember -Identity $DistributionGroupName | Select-Object PrimarySMTPAddress
        $IsAlreadyMember = $false

        # Verifying if the user is not already in the distribution group
        foreach ($Member in $DLMembers) {
            if ($Member.PrimarySMTPAddress -eq $UserIdentity) {
                $IsAlreadyMember = $True
            }
        }

        # If the user is not already in the distribution group, adding him or her
        if ($IsAlreadyMember -eq $false) {
            Add-DistributionGroupMember -Identity $DistributionGroupName -Member $UserIdentity -ErrorAction Stop | Out-Null
            Write-Output "Done adding $UserIdentity to $DistributionGroupName distribution group"
        } else {
            Write-Warning "$UserIdentity is already in the distribution group $DistributionGroupName !"
        }
    }

    # Catching error if there is an error in the distribution group name or the email address
    catch {
        Write-Error "Error adding $UserIdentity to $DistributionGroupName distribution group ! Verify the name of the group and the distribution group and try again !"
    }

Get-PSSession | Remove-PSSession