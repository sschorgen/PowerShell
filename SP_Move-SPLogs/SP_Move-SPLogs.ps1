<#
    .SYNOPSIS
        Move SharePoint Logs
    .DESCRIPTION
        Move SharePoint ULS + Health & Usage Logs
    .PARAMETER ULSLog
        Specify your ULS log file path. Example : E:\SharePoint\Logs\ULS
    .PARAMETER UsageHealthLog
        Specify your ULS log file path. Example : E:\SharePoint\Logs\ULS
    .EXAMPLE
        .\SP_Move-SPLogs.ps1 -ULSLog "E:\SharePoint\Logs\ULS" -UsageHealthLog "E:\SharePoint\Logs\UsageHealth"
        This will create a new log file containing all AD Objects by AD Groups
    .NOTES
        Author : Sylver SCHORGEN
        Blog : http://microsofttouch.fr/default/b/sylver
        Created : 25 feb. 2015
        @sylver_schorgen
#>


Param(
    [Parameter(Mandatory=$true)]
    [string]$ULSLog,
    [Parameter(Mandatory=$true)]
    [string]$UsageHealthLog
)

Write-Host
Write-Host
Write-Host "Setting up initial variables ... " -NoNewLine

# Load PSSnapin for SharePoint
if((Get-PSSnapin "Microsoft.SharePoint.PowerShell" -ErrorAction SilentlyContinue) -eq $null)
{
      Add-PSSnapin Microsoft.SharePoint.PowerShell
}

Write-Host "Ok !" -ForeGroundColor Green
Write-Host

# Move SharePoint Logs to locations specify by the administrator
try {
    Write-Host "Moving SharePoint ULS Log to $ULSLog  ... " -NoNewLine
    
    Set-SPDiagnosticConfig -LogLocation $ULSLog
    
    Write-Host "Ok !" -ForeGroundColor Green
    Write-Host
}
catch {
    Write-Host "Error while moving ULS Logs !" -ForeGroundColor Red
    Write-Host
    Write-Host $_.Exception.Message
}
try {
    Write-Host "Moving SharePoint Health & Usage Log to $UsageHealthLog  ... " -NoNewLine
    
    set-SPUsageService -UsageLogLocation $UsageHealthLog
    
    Write-Host "Ok !" -ForeGroundColor Green
    Write-Host
}
catch {
    Write-Host "Error while moving Health & Usage Logs !" -ForeGroundColor Red
    Write-Host
    Write-Host $_.Exception.Message
}




