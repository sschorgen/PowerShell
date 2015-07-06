Function Set-TimeZone {

    <#

        .SYNOPSIS
            Script used to configure Time Zone
        .DESCRIPTION
            Script used to configure Time Zone
        .PARAMETER Name
            Specify the Name of your time zone (a list is available here : https://goo.gl/oHTVvH)
        .EXAMPLE
            .\SERVER_Set-TimeZone.ps1 -Name "New Caledonia"
            This will configure the time zone to UTC + 11:00
        .NOTES
            Author : Sylver SCHORGEN
            Blog : http://microsofttouch.fr/default/b/sylver
            Created : 07 july 2015
            @sylver_schorgen
    #>

    param (
        [Parameter(ValueFromPipeline = $True, Mandatory=$true)]
        [string]$Name
    )

    Write-Host "Setting up initial variables ..." -NoNewline
    
    try {
        $TimeZone = [system.timezoneinfo]::GetSystemTimeZones() | Where {($_.ID -like "*$Name*") -or ($_.DisplayName -like "*$Name*")} | Select -ExpandProperty ID
        Write-Host " Done !" -ForegroundColor Green
    }
    catch {
        Write-Host "Error during the initial set up of the variables!" -ForegroundColor Red
    }

    Write-Host "Configuring time zone to $TimeZone..." -NoNewline
    try {
        tzutil.exe /s "$TimeZone"
        Write-Host "Done !" -ForegroundColor Green
    }
    catch {
        Write-Host "Error configuring time zone !" -ForegroundColor Red
    }
}