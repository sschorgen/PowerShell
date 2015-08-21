<#
    .SYNOPSIS
        Create User Accounts for SharePoint and SQL Server
    .DESCRIPTION
        Create User Accounts for SharePoint and SQL Server
    .PARAMETER OU
        Specify your Active Directory Organizational Unit where you store user accounts
    .EXAMPLE
        .\AD_Add-ADUserAccounts.ps1 -OU "OU=User Accounts,OU=LAB,DC=lab,DC=local"
        This will create all user accounts added in the xml file UserAccounts.xml. This file must be in the same folder as the script file.
    .NOTES
        Author : Sylver SCHORGEN
        Blog : http://microsofttouch.fr/default/b/sylver
        Created : 21 aug. 2015
        @sylver_schorgen
#>


Param(
    [Parameter(Mandatory=$true)]
    [string]$OU
)



# Setting up variables required for the script
Write-Host
Write-Host
Write-Host "Setting up initial variables ... " -NoNewLine

$xmlFilePath = "UserAccounts.xml"
$domain = [System.DirectoryServices.ActiveDirectory.Domain]::GetCurrentDomain().Name

Write-Host "Ok !" -ForeGroundColor Green
Write-Host
Write-Host "Getting all user accounts from the XML file ..." -NoNewLine

[xml]$file = get-content $xmlFilePath

Write-Host "Ok !" -ForeGroundColor Green
Write-Host
Write-Host "Creating all user accounts ..."

# Getting all user informations stored in <User> xml tag
foreach ($account in $file.UserAccounts.User) {
    $fullName = $account.firstname + " " + $account.lastname
    $userName = $account.UserName
    $firstname = $account.Firstname
    $lastname = $account.Lastname
    $upn = "$userName@$domain"
    $description = $account.Description
    $securepassword = ""
    if ($file.UserAccounts.GlobalPassword -ne "") {
        $securePassword = $file.UserAccounts.GlobalPassword | ConvertTo-SecureString -AsPlainText -Force
    }
    else {
        $securePassword = $account.Password | ConvertTo-SecureString -AsPlainText -Force
    }
    $userExist = Get-ADUser -Filter "Name -eq '$fullName'"

    if ($userExist -eq $null) {
	    try {
		    # User account creation
		    New-ADUser -GivenName $firstname -Surname $lastname -DisplayName:$fullName -Name:$fullName -Path:$ou -SamAccountName:$userName -Type:"user" -UserPrincipalName:$upn

		    # User account password assignment
		    Set-ADAccountPassword -Identity:"CN=$fullName,$ou" -Reset:$null -NewPassword $securePassword
		
		    # User account activation
		    Enable-ADAccount -Identity:"CN=$fullName,$ou"
		
		    # Setting up User account properties
		    Set-ADAccountControl -Identity:"CN=$fullName,$ou" -AccountNotDelegated:$false -AllowReversiblePasswordEncryption:$false -CannotChangePassword:$true -DoesNotRequirePreAuth:$false -PasswordNeverExpires:$true -UseDESKeyOnly:$false
		    Set-ADUser -Identity:"CN=$fullName,$ou" -ChangePasswordAtLogon:$false -SmartcardLogonRequired:$false
		
		    Write-Host " -- Account $fullName successfully created !" -ForeGroundColor Green
	    }
	    catch {
		    Write-Host " -- Error creating $fullName account !" -ForeGroundColor Red
	    }
    }
    else {
	    Write-Host " -- Acount $fullName already exists !"
    }	
}