<#

        .SYNOPSIS
            Script used to get unlicensed Office 365 users
        .DESCRIPTION
            Script used to get unlicensed Office 365 users and generate a CSV file
        .PARAMETER CSVFilePath
            Specify a csv file path used to save the unlicensed users in a csv file.
            Default value is your user desktop
        .PARAMETER O365AdminLogin
            Specify an Office 365 administrator login
        .PARAMETER O365AdminPassword
            Specify an Office 365 administrator password
        .EXAMPLE
            .\O365_Get-UnlicensedUsers.ps1 -CSVFilePath "C:\_\unlicensed_users.csv" -O365AdminLogin "admin@domain.com" -O365AdminPassword "XXXXYYYY"
            This will list all your Office 365 unlicensed users
        .NOTES
            Author : Sylver SCHORGEN
            Blog : http://microsofttouch.fr/default/b/sylver
            Created : 12 july 2016
            @sylver_schorgen
#>

param (
	[Parameter(Mandatory=$false)]
	[string]$CSVFilePath = $env:HOMEDRIVE + $env:HOMEPATH + "\desktop\unlicensed_users.csv",
	[Parameter(Mandatory=$true)]
	[string]$O365AdminLogin,
	[Parameter(Mandatory=$true)]
	[string]$O365AdminPassword
)

#region Variables

Write-Host "Setting up initial variables ..." -NoNewline

try {
	$ComputerName = $env:computername
	$OSLanguage = Get-WmiObject Win32_OperatingSystem -ComputerName $ComputerName -ErrorAction SilentlyContinue | foreach {$_.oslanguage}
    
    Switch($OSLanguage) {
	    #English-USA
	    1033 {
		    $Name = "Name"
		    $UPN = "User Principal Name"
		    $Licensed = "Licensed ?"
	    }
	    #English-UK
	    2057 {
		    $Name = "Name"
		    $UPN = "User Principal Name"
		    $Licensed = "Licensed ?"
	    }
	    #French-Standard
	    1036 {
		    $Name = "Nom"
		    $UPN = "User Principal Name"
		    $Licensed = "Dispose d'une licence ?"
	    }
	    #French-Belgian
	    2060 {
		    $Name = "Nom"
		    $UPN = "User Principal Name"
		    $Licensed = "Dispose d'une licence ?"
	    }
	    #French-Canadian
	    3084 {
		    $Name = "Nom"
		    $UPN = "User Principal Name"
		    $Licensed = "Dispose d'une licence ?"
	    }
	    #French-Swiss
	    4108 {
		    $Name = "Nom"
		    $UPN = "User Principal Name"
		    $Licensed = "Dispose d'une licence ?"
	    }
	    #French-Luxembourg
	    5132 {
		    $Name = "Nom"
		    $UPN = "User Principal Name"
		    $Licensed = "Dispose d'une licence ?"
	    }
	    #French-Monaco
	    6156 {
		    $Name = "Nom"
		    $UPN = "User Principal Name"
		    $Licensed = "Dispose d'une licence ?"
	    }
	    default {
		    $Name = "Name"
		    $UPN = "User Principal Name"
		    $Licensed = "Licensed ?"
	    }
    }

	Write-Debug "ComputerName variable value --> $ComputerName"
	Write-Debug "OSLanguage variable value --> $OSLanguage"
    Write-Debug "Name variable value --> $Name"
    Write-Debug "UPN variable value --> $UPN"
    Write-Debug "Licensed variable value --> $Licensed"

	Write-Host " Done !" -ForegroundColor Green
}
catch {
	Write-Host " Error setting up localized variables based on OS language for the CSV columns names !" -ForegroundColor Red
}

#endregion

#region Connect to Office 365

$Login = $O365AdminLogin
$Password = $O365AdminPassword | ConvertTo-SecureString -AsPlainText -Force
$Credentials = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $Login, $Password
$UnlicensedUsers

Write-Host "Connecting to Office 365 tenant ..." -NoNewline

try {
    Connect-MsolService -Credential $Credentials -ErrorAction Stop | Out-Null
    
    Write-Host " Done !" -ForegroundColor Green
}catch {
    Write-Host " Error connecting to your Office 365 tenant ! Verify your login and password and try again !" -ForegroundColor Red
}

#endregion

#region Get Unlicensed Users and Export to CSV

try{

    Write-Host "Getting all unlicensed users ..." -NoNewline

    $UnlicensedUsers = Get-MsolUser | Select UserPrincipalName,DisplayName,UserType,isLicensed,CloudExchangeRecipientDisplayType `
    | Where {($_.islicensed -eq $false) -and ($_.UserType -eq "Member") -and ($_.CloudExchangeRecipientDisplayType -ne 1) `
    -and ($_.CloudExchangeRecipientDisplayType -ne 2) -and ($_.CloudExchangeRecipientDisplayType -ne 3) -and ($_.CloudExchangeRecipientDisplayType -ne 4) `
    -and ($_.CloudExchangeRecipientDisplayType -ne 5) -and ($_.CloudExchangeRecipientDisplayType -ne 6) -and ($_.CloudExchangeRecipientDisplayType -ne 7) `
    -and ($_.CloudExchangeRecipientDisplayType -ne 8)} `
    | Select @{Name=$UPN;Expression={$_.UserPrincipalName}},@{Name=$Name;Expression={$_.DisplayName}},@{Name=$Licensed;Expression={$_.isLicensed}}
    
    Write-Debug "Number of unlicensed users --> $UnlicensedUsers.Count"
    Write-Host " Done !" -ForegroundColor Green

} catch {
    Write-Host " Error getting unlicensed users !" -ForegroundColor Red
}

try{
    Write-Host "Exporting unlicensed users to CSV file $CSVFilePath ..." -NoNewline

    $UnlicensedUsers | Export-CSV $CSVFilePath -NoTypeInformation -Encoding Default

    Write-Host " Done !" -ForegroundColor Green
}catch {
    Write-Host " Error exporting the CSV file ! Please verify the path is correct and try again !" -ForegroundColor Red
}


#endregion