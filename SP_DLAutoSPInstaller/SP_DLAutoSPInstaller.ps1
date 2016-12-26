<#
    .SYNOPSIS
        Script used to download AutoSPInstaller
    .DESCRIPTION
        Script used to download AutoSPInstaller
        The CSV configuration file linked to this script is used to modify the AutoSPInstaller download link
    .PARAMETER CSVFilePath
        The path of the CSV file containing the URL of the latest AutoSPInstaller ZIP
        This parameter is not mandatory. The default value is SP_DLAutoSPInstallerConfiguration.csv
        The CSV file must be in the same folder as SP_DLAutoSPInstallerConfiguration.ps1
    .PARAMETER DestinationFolder
        The path of the folder where AutoSPInstaller will be unzipped
        This parameter is not mandatory. The default value is C:\Users\YOURUSERNAME\Downloads"
    .EXAMPLE
        .\SP_DLAutoSPInstallerConfiguration.ps1
        This will download the latest version of AutoSPInstaller in C:\Users\YOURUSERNAME\Downloads and unzip it in the folder C:\Users\YOURUSERNAME\Downloads\AutoSPInstaller
        If the Zip file already existed in the Downloads folder, it will be automatically removed
        If the AutoSPInstaller folder already existed in the Downloads folder, it will be automatically removed
    .EXAMPLE
        .\SP_DLAutoSPInstallerConfiguration.ps1 -DestinationFolder "C:\_sources"
        This will download the latest version of AutoSPInstaller in the folder C:\_sources and unzip it in the folder C:\_sources\AutoSPInstaller
        If the Zip file already existed in the Downloads folder before the execution of the script, it will be automatically removed
        If the AutoSPInstaller folder already existed in the Downloads folder before the execution of the script, it will be automatically removed
    .NOTES
        Author : Sylver SCHORGEN
        Blog : http://microsofttouch.fr/default/b/sylver
        Created : 26 dec. 2016
        @sylver_schorgen
#>

param (
    [Parameter(Mandatory=$false)]
    [string] $CSVFilePath = "SP_DLAutoSPInstallerConfiguration.csv",
    [Parameter(Mandatory=$false)]
    [string] $DestinationFolder = "$env:USERPROFILE\Downloads"
)

#Function used to Download AutoSPInstaller from Codeplex
Function Download-AutoSPInstaller {

    param (
        [Parameter(Mandatory=$false)]
        [string] $CSVFilePath = "SP_DLAutoSPInstallerConfiguration.csv",
        [Parameter(Mandatory=$false)]
        [string] $DestinationFolder = "$env:USERPROFILE\Downloads"
    )

    Write-Host ""
    Write-Host "Setting up varibles ... " -NoNewline

    $CSV = Import-CSV $CSVFilePath -Delimiter ";"
    $DownloadURL = $CSV.Link
    $DestinationFile = "$DestinationFolder\$($CSV.ExpandFile).zip"
    $UnzippedFolder = "$DestinationFolder\$($CSV.ExpandFile)"

    Write-Host " OK !" -ForegroundColor Green

    Try{

        if(Test-Path $DestinationFile) {
            Write-Host ""
            Write-Host "AutoSPInstaller ZIP already exists! Removing ... " -NoNewline

            Remove-Item -Path $DestinationFile -Force -Confirm:$false
            
            Write-Host " OK !" -ForegroundColor Green
        }
        
        Write-Host ""
        Write-Host "Downloading AutoSPInstaller ... " -NoNewline

        Invoke-WebRequest -Uri $DownloadURL -OutFile $DestinationFile
        
        Write-Host " OK !" -ForegroundColor Green

        if(Test-Path "$UnzippedFolder") {
            Write-Host ""
            Write-Host "AutoSPInstaller folder already exists! Removing ... " -NoNewline

            Remove-Item -Path $UnzippedFolder -Recurse -Force -Confirm:$false
            
            Write-Host " OK !" -ForegroundColor Green
        }

        Try {
            Write-Host ""
            Write-Host "Unzipping AutoSPInstaller Folders Structure ... " -NoNewline

            Unzip-File -ZipFilePath "$DestinationFile" -DestinationPath "$UnzippedFolder"

            Write-Host " OK !" -ForegroundColor Green
        } Catch {
            Write-Host "Error ! Verify AutoSPInstaller has been correctly downloaded !"
        }


    } Catch {
        Write-Host "Error ! Verify your Internet connection !"
    }

}

#Function used to unzip AutoSPInstaller.zip
Function Unzip-File {

    param (
        [Parameter(Mandatory=$True)]
        [string] $ZipFilePath,
        [Parameter(Mandatory=$True)]
        [string] $DestinationPath = "$env:USERPROFILE\Downloads"
    )
    
    Add-Type -AssemblyName System.IO.Compression.FileSystem

    [System.IO.Compression.ZipFile]::ExtractToDirectory($ZipFilePath, $DestinationPath)
}


Download-AutoSPInstaller