<#
    .SYNOPSIS
        Create Service Accounts for SharePoint and SQL Server
    .DESCRIPTION
        Create Service Accounts for SharePoint and SQL Server
    .PARAMETER SharePointOU
        Specify your Active Directory Organizational Unit where you store your SharePoint service accounts
    .PARAMETER SQLOU
        Specify your Active Directory Organizational Unit where you store your SQL service accounts
    .EXAMPLE
        .\AD_Add-ADServiceAccounts.ps1 -SharePointOU "OU=SharePoint,OU=Service Accounts,OU=LAB,DC=lab,DC=local" -SQLOU "OU=SQL,OU=Service Accounts,OU=LAB,DC=lab,DC=local"
        This will create all service accounts added in the xml file ServiceAccounts.xml. This file must be in the same folder as the script file.
    .NOTES
        Author : Sylver SCHORGEN
        Blog : http://microsofttouch.fr/default/b/sylver
        Created : 04 mar. 2015
        Updated : 07 dec. 2016
        @sylver_schorgen
#>


Param(
    [Parameter(Mandatory=$false)]
    [string]$SharePointOU,
    [Parameter(Mandatory=$false)]
    [string]$SQLOU
)



# Setting up variables required for the script
Write-Host
Write-Host
Write-Host "Setting up initial variables ... " -NoNewLine

$serverName = [system.environment]::MachineName
$xmlFilePath = "ServiceAccounts.xml"
$domain = [System.DirectoryServices.ActiveDirectory.Domain]::GetCurrentDomain().Name
$server = "$serverName.$domain"

Write-Host "Ok !" -ForeGroundColor Green
Write-Host
Write-Host "Getting all service accounts from the XML file ..." -NoNewLine

[xml]$file = get-content $xmlFilePath

Write-Host "Ok !" -ForeGroundColor Green
Write-Host
Write-Host "Creating all service accounts ..."

# Getting all user informations stored in <User> xml tag
foreach ($account in $file.ServiceAccounts.User) {
    $fullName = $account.UserName
    $userName = $account.UserName
    $upn = "$userName@$domain"
    $description = $account.Description
    $securepassword = ""
    if ($file.ServiceAccounts.GlobalPassword -ne "") {
        $securePassword = $file.ServiceAccounts.GlobalPassword | ConvertTo-SecureString -AsPlainText -Force
    }
    else {
        $securePassword = $account.Password | ConvertTo-SecureString -AsPlainText -Force
    }
    $userExist = Get-ADUser -Filter {Name -eq $fullName}
    $ou = ""

    if($account.Type -eq "SharePoint") {
	    $ou = $sharepointOU
    }
    elseif($account.Type -eq "Sql") {
	    $ou = $sqlOU
    }

    if ($userExist -eq $null) {
	    try {
		    # Service account creation
		    New-ADUser -DisplayName:$fullName -Name:$fullName -Path:$ou -SamAccountName:$userName -Server:$server -Type:"user" -UserPrincipalName:$upn -Description $description
		
		    # Service account password assignment
		    Set-ADAccountPassword -Identity:"CN=$fullName,$ou" -Reset:$null -Server:$server -NewPassword $securePassword
		
		    # Service account activation
		    Enable-ADAccount -Identity:"CN=$fullName,$ou" -Server:$server
		
		    # Setting up service account properties
		    Set-ADAccountControl -Identity:"CN=$fullName,$ou" -AccountNotDelegated:$false -AllowReversiblePasswordEncryption:$false -CannotChangePassword:$true -DoesNotRequirePreAuth:$false -PasswordNeverExpires:$true -Server:$server -UseDESKeyOnly:$false
		    Set-ADUser -Identity:"CN=$fullName,$ou" -ChangePasswordAtLogon:$false -Server:$server -SmartcardLogonRequired:$false
		
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