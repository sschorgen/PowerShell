<#
    .SYNOPSIS
        Get all your Office 365 distribution groups with members
    .DESCRIPTION
        Get all your Office 365 distribution groups with members in every groups
    .PARAMETER O365AdminLogin
        Specify an Office 365 Administrator
    .PARAMETER O365AdminPassword
        Specify the Office 365 Administrator password
    .PARAMETER CSVFilePath
        Specify a file path for the CSV that is going to be exported
    .EXAMPLE
        .\Get-O365DLWithMembers.ps1 -O365AdminLogin "admin@mytenant.onmicrosoft.com" -O365AdminPassword "MYPASSWORD" -CSVFilePath "C:\_\myCsvFile.csv"
        This will export all my distribution groups in the CSV located here : C:\_\myCsvFile.csv
    .NOTES
        Author : Sylver SCHORGEN
        Blog : http://microsofttouch.fr/default/b/sylver
        Created : 12 mar. 2016
        Twitter : @sylver_schorgen
#>

Param(
    [Parameter(Mandatory=$true)]
    [string]$O365AdminLogin,
    [Parameter(Mandatory=$true)]
    [string]$O365AdminPassword,
    [Parameter(Mandatory=$true)]
    [string]$CSVFilePath
)

# Setting up variables required for the script
Write-Host
Write-Host
Write-Host "Setting up initial variables ... " -NoNewLine

$O365SecureAdminPassword = ConvertTo-SecureString -AsPlainText $O365AdminPassword -Force
$Cred  = New-Object System.Management.Automation.PSCredential ($O365AdminLogin,$O365SecureAdminPassword)
Out-File -FilePath $CSVFilePath -InputObject "DL Display name;DL Email Address;Members DisplayName" -Encoding UTF8

Write-Host "Ok !" -ForeGroundColor Green
Write-Host

Write-Host
Write-Host "Connecting to Exchange Online ... " -NoNewLine

try {
    # Connect to Exchange Online with a PowerShell Session
    $Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://outlook.office365.com/powershell-liveid/ -Credential $Cred -Authentication Basic –AllowRedirection -ErrorAction Stop
    Import-PSSession $Session -AllowClobber

    Write-Host "Ok !" -ForeGroundColor Green
    Write-Host
} catch {
    Write-Host "Error connecting to Exchange Online !" -ForeGroundColor Red
    Write-Host
    Exit
}

Write-Host
Write-Host "Getting all distribution groups ... " -NoNewLine

try {
    # Getting all distribution groups
    $Groups = Get-DistributionGroup -ResultSize Unlimited -ErrorAction Stop

    Write-Host "Ok !" -ForeGroundColor Green
    Write-Host
} catch {
    Write-Host "Error getting all distribution groups !" -ForeGroundColor Red
    Write-Host
    Exit
}

Foreach($Group in $Groups) {
    
    Write-Host
    Write-Host "Getting all members of $($Group.Name) distribution group ... " -NoNewLine

    # Getting all group members
    $Members = Get-DistributionGroupMember -Identity $($Group.PrimarySmtpAddress) | Select Name

    foreach($Member in $Members) {
        
        # Adding group members in the CSV file
        Out-File -FilePath $CSVFilePath -InputObject "$($Group.DisplayName);$($Group.PrimarySMTPAddress);$($Member.Name)" -Encoding UTF8 -Append

    }

    Write-Host "Ok !" -ForeGroundColor Green
    Write-Host

}

# Removing PSSession with Exchange Online
Remove-PSSession -Session $Session

Write-Host
Write-Host "Restults has been exported to $CSVFilePath" -ForegroundColor White