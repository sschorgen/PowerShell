<#
    .SYNOPSIS
        Install Windows Server 2012 or 2012R2 prerequisites for Office Web Apps 2013 installation
    .DESCRIPTION
        Install Windows Server 2012 or 2012R2 prerequisites for Office Web Apps 2013 installation
    .PARAMETER SXSFolder
        Specify the location of the Windows Server 2012 or 2012R2 SXS folder.
        You can 
    .EXAMPLE
        .\OWA13_Install-ServerPrerequisites.ps1 -SXSFolder "D:\Sources\sxs"
        This will install mandatory prerequisites for OWA 13 installation.
    .NOTES
        Author : Sylver SCHORGEN
        Blog : http://microsofttouch.fr/default/b/sylver
        Created : 12 apr. 2015
        @sylver_schorgen
#>

Param(
    [Parameter(Mandatory=$true)]
    [string]$SXSFolder
)


# Installing Prerequisites
Write-Host
Write-Host
Write-Host "Installing prerequisites for OWA 2013 ... "
Write-Host

try {
	Add-WindowsFeature Web-Server,Web-Mgmt-Tools,Web-Mgmt-Console,Web-WebServer,Web-Common-Http,Web-Default-Doc,Web-Static-Content,Web-Performance,Web-Stat-Compression,Web-Dyn-Compression,Web-Security,Web-Filtering,Web-Windows-Auth,Web-App-Dev,Web-Net-Ext45,Web-Asp-Net45,Web-ISAPI-Ext,Web-ISAPI-Filter,Web-Includes,InkandHandwritingServices -Source $SXSFolder

	Write-Host
	Write-Host "Prerequisites for OWA 2013 installed !" -ForeGroundColor Green
	Write-Host

}
catch {
	Write-Host "Error installing prerequisites for OWA 2013" -ForeGroundColor Red
}