<#
    .SYNOPSIS
        Script used to download SharePoint 2016 prerequisites, language pack, cumulative updates and services pack
    .DESCRIPTION
        Script used to download SharePoint 2016 prerequisites, lp, cu, sp based on a XML file that contains the link
    .PARAMETER XmlFilePath
        The path of the XML file containing the URLs for the prerequisites, CU and language pack
        This parameter is not mandatory. The default value is SP16DownloadConfiguration.xml
        The XML file must be in the same folder as SP16_Download-PrerequisitesCULP.ps1
    .PARAMETER CSVFilePath
        The path of the CSV file containing the URL of the latest AutoSPInstaller ZIP
        This parameter is not mandatory. The default value is SP_DLAutoSPInstallerConfiguration.csv
        The CSV file must be in the same folder as SP16_Download-PrerequisitesCULP.ps1
    .PARAMETER DestinationFolder
        The path of the folder in which all the .exe, .msi and .msu will be downloaded
        This parameter is not mandatory. The default value is C:\_SP16SOURCES"
        You must never write a "\" at the end of this folder path
    .PARAMETER Language
        The language pack you want to download
        This parameter is not mandatory. You must enter a value formatted like en-us or fr-fr
        The languages packs managed are fr-fr, en-us, es-es and it-it
    .PARAMETER CumulativeUpdate
        The CU of SharePoint 2016 you want to download
        This parameter is not mandatory. The default value is December 2016
    .EXAMPLE
        .\SP16_Download-PrerequisitesCULP.ps1
        This will download AutoSPInstaller.zip and unzip it in C:\_SP16SOURCES\AutoSPInstaller
        This will download SharePoint 2016 prerequisistes in the folder C:\_SP16SOURCES\AutoSPInstaller\SP\2016\SharePoint\Prerequisites
        This will download SharePoint 2016 December 2016 CU in the folder C:\_SP16SOURCES\AutoSPInstaller\SP\2016\Updates
        This will download SharePoint 2016 fr-fr language pack in the folder C:\_SP16SOURCES\AutoSPInstaller\SP\2016\LanguagePacks
    .EXAMPLE
        .\SP16_Download-PrerequisitesCULP.ps1 -XmlFilePath "SP16DownloadConfiguration.xml" -DestinationFolder "D:\_sp16" -Language "fr-fr" -CumulativeUpdate "November 2016"
        This will download AutoSPInstaller.zip and unzip it in D:\_sp16\AutoSPInstaller
        This will download SharePoint 2016 prerequisistes in the folder D:\_sp16\AutoSPInstaller\SP\2016\SharePoint\Prerequisites
        This will download SharePoint 2016 November 2016 CU in the folder D:\_sp16\AutoSPInstaller\SP\2016\Updates
        This will download SharePoint 2016 fr-fr language pack in the folder D:\_sp16\AutoSPInstaller\SP\2016\LanguagePacks
    .NOTES
        Author : Sylver SCHORGEN
        Blog : http://microsofttouch.fr/default/b/sylver
        Created : 07 dec. 2016
        Updated : 26 dec. 2016
        @sylver_schorgen
#>


param (
    [Parameter(Mandatory=$false)]
    [string] $XmlFilePath = "SP16DownloadConfiguration.xml",
    [Parameter(Mandatory=$false)]
    [string] $CSVFilePath = "SP_DLAutoSPInstallerConfiguration.csv",
    [Parameter(Mandatory=$false)]
    [string] $DestinationFolder = "C:\_SP16SOURCES",
    [Parameter(Mandatory=$false)]
    [string] $Language = "fr-fr",
    [Parameter(Mandatory=$false)]
    [string] $CumulativeUpdate = "January 2017"
)


[xml]$Xml = Get-Content $XmlFilePath
$CSV = Import-CSV $CSVFilePath -Delimiter ";"
$DownloadURL = $CSV.Link
$DestinationFile = "$DestinationFolder\$($CSV.ExpandFile).zip"
$UnzippedFolder = "$DestinationFolder\$($CSV.ExpandFile)"
$PrerequisitesFolder = $UnzippedFolder + "\SP\2016\SharePoint\Prerequisites"
$CUFolder = $UnzippedFolder + "\SP\2016\Updates"
$LanguagePackFolder = $UnzippedFolder + "\SP\2016\LanguagePacks\$Language"

#Function used to Download AutoSPInstaller from Codeplex
Function Download-AutoSPInstaller {

    param (
        [Parameter(Mandatory=$false)]
        [string] $CSVFilePath = "SP_DLAutoSPInstallerConfiguration.csv",
        [Parameter(Mandatory=$false)]
        [string] $DestinationFolder = "$env:USERPROFILE\Downloads"
    )

    Write-Host ""
    Write-Host " -- Setting up varibles ... " -NoNewline

    Write-Host " OK !" -ForegroundColor Green

    Try{
        if(!(Test-Path $DestinationFile)) {
            Write-Host ""
            Write-Host " -- Downloading AutoSPInstaller ... " -NoNewline

            Invoke-WebRequest -Uri $DownloadURL -OutFile $DestinationFile
        
            Write-Host " OK !" -ForegroundColor Green
        }

        if(!(Test-Path "$UnzippedFolder")) {
            Try {
                Write-Host ""
                Write-Host " -- Unzipping AutoSPInstaller Folders Structure ... " -NoNewline

                Unzip-File -ZipFilePath "$DestinationFile" -DestinationPath "$UnzippedFolder"

                Write-Host " OK !" -ForegroundColor Green
            } Catch {
                Write-Host "Error ! Verify AutoSPInstaller has been correctly downloaded !"
            }
        }

        if((Test-Path "$UnzippedFolder\SP\2013")) {
            Remove-Item -Path "$UnzippedFolder\SP\2013" -Force -Confirm:$false -Recurse
        }
        if((Test-Path "$UnzippedFolder\SP\2010")) {
            Remove-Item -Path "$UnzippedFolder\SP\2010" -Force -Confirm:$false -Recurse
        }


    } Catch {
        Write-Host "Error ! Verify your Internet connection !"
    }

    Remove-Item -Path $DestinationFile -Force -Confirm:$false

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

# Function used to verify the folder structure
function Test-FoldersPath
{
    Write-Host ""
    Write-Host "### VERIFYING FOLDER STRUCTURE ###"
    
    Write-Host " -- Folder $DestinationFolder ..." -NoNewline
    
    if(!(Test-Path $DestinationFolder)) {
        New-Item -Path $DestinationFolder -ItemType Directory | Out-Null
        Write-Host " has been created !" -ForegroundColor Green
    } else {
        Write-Host " already exists !" -ForegroundColor Yellow
    }
    
    Download-AutoSPInstaller

    Write-Host ""
    Write-Host " -- Folder $PrerequisitesFolder ..." -NoNewline
    
    if(!(Test-Path $PrerequisitesFolder)) {
        New-Item -Path $PrerequisitesFolder -ItemType Directory | Out-Null
        Write-Host " has been created !" -ForegroundColor Green
    } else {
        Write-Host " already exists !" -ForegroundColor Yellow
    }
    
    Write-Host " -- Folder $CUFolder ..." -NoNewline
    
    if(!(Test-Path $CUFolder)) {
        New-Item -Path $CUFolder -ItemType Directory | Out-Null
        Write-Host " has been created !" -ForegroundColor Green
    } else {
        Write-Host " already exists !" -ForegroundColor Yellow
    }
    
    Write-Host " -- Folder $LanguagePackFolder ..." -NoNewline
    
    if(!(Test-Path $LanguagePackFolder)) {
        New-Item -Path $LanguagePackFolder -ItemType Directory | Out-Null
        Write-Host " has been created !" -ForegroundColor Green
    } else {
        Write-Host " already exists !" -ForegroundColor Yellow
    }

    Write-Host ""
}

# Function used to download SharePoint 2016 prerequisites
function Download-SP16Prerequisites {

    Write-Host "### DOWNLOADING SHAREPOINT 2016 PREREQUISITES ###"
    $Item = ""
    
    foreach($Prerequisite in $Xml.Product.Prerequisites.Prerequisite) {
        $File = $Prerequisite.Url.Split('/')[-1]
        $FilePath = $PrerequisitesFolder + "\" + $File
        
        if(!(Test-Path $FilePath)) {
                Try {
                    Write-Host " -- Downloading $File ..." -NoNewline
                    Start-BitsTransfer -Source $Prerequisite.Url -Destination "$PrerequisitesFolder" -DisplayName "Downloading `'$file`' to $PrerequisitesFolder" -Priority Foreground -Description "From $($Prerequisite.Url)..." -RetryInterval 60 -RetryTimeout 3600 -ErrorVariable err
                    Write-Host " OK !" -ForegroundColor Green
                } Catch {
                    Write-Host "Error downloading $File. Verify your Internet Connection and retry !" -ForegroundColor Red
                }
            } else {
                Write-Host " -- Downloading $File ..." -NoNewline
                Write-Host " Already downloaded !" -ForegroundColor Yellow
            }
        }
    
    Write-Host ""
}

# Function used to download SharePoint 2016 cumulative updates
function Download-SP16CU
{
 
    $CUExists = $false   
    Write-Host "### DOWNLOADING SHAREPOINT 2016 CUMULATIVE UPDATES ###"
    
    foreach($CU in $Xml.Product.CumulativeUpdates.CumulativeUpdate) {
        
        if($CU.Name -eq $CumulativeUpdate) {
            $File = $CU.Url.Split('/')[-1]
            $FilePath = $CUFolder + "\" + $File
        
            if (!(Test-Path $FilePath)) {
                
                Try {
                    Write-Host " -- Downloading $File ..." -NoNewline
                    Start-BitsTransfer -Source $CU.Url -Destination "$CUFolder" -DisplayName "Downloading `'$file`' to $CUFolder" -Priority Foreground -Description "From $($CU.Url)..." -RetryInterval 60 -RetryTimeout 3600 -ErrorVariable err
                    Write-Host " OK !" -ForegroundColor Green
                } Catch {
                    Write-Host "Error downloading $File. Verify your Internet Connection and retry !" -ForegroundColor Red
                }

            } else {
                Write-Host " -- Downloading $File ..." -NoNewline
                Write-Host " Already downloaded !" -ForegroundColor Yellow
            }
        }
    }
    
    Write-Host ""

}

# Function used to download SharePoint 2016 language packs
function Download-SP16LP
{
    
    Write-Host "### DOWNLOADING SHAREPOINT 2016 LANGUAGE PACK ###"
    
    foreach($LP in $Xml.Product.LanguagePacks.LanguagePack) {
        
        if($LP.Name -eq $Language) {
            $File = $LP.Url.Split('/')[-1]
            $FilePath = $LanguagePackFolder + "\" + $File
        
            if (!(Test-Path $FilePath)) {
                Try {
                    Write-Host " -- Downloading $File ..." -NoNewline
                    Start-BitsTransfer -Source $LP.Url -Destination "$LanguagePackFolder" -DisplayName "Downloading `'$file`' to $LanguagePackFolder" -Priority Foreground -Description "From $($LP.Url)..." -RetryInterval 60 -RetryTimeout 3600 -ErrorVariable err

                    Set-Location $LanguagePackFolder
                    Start-Process .\$File -Argumentlist "/extract:$LanguagePackFolder /Q" -Wait
                    Remove-Item $FilePath

                    Write-Host " OK !" -ForegroundColor Green
                } Catch {
                    Write-Host "Error downloading $File. Verify your Internet Connection and retry !" -ForegroundColor Red
                }
            } else {
                Write-Host " -- Downloading $File ..." -NoNewline
                Write-Host " Already downloaded !" -ForegroundColor Yellow
            }
        }
    }
    
    Write-Host ""

}

Test-FoldersPath
Download-SP16Prerequisites
Download-SP16CU
Download-SP16LP