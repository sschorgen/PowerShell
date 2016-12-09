<#
    .SYNOPSIS
        Script used to download Office Online 2016 prerequisites and language pack
    .DESCRIPTION
        Script used to download Office Online 2016 prerequisites and language pack based on a XML file that contains the links
    .PARAMETER XmlFilePath
        The path of the XML file containing the URLs for the prerequisites and language pack
        This parameter is not mandatory. The default value is OOS16DownloadConfiguration.xml
        The XML file must be in the same folder as OOS16_Download-PrerequisitesLP.ps1
    .PARAMETER DestinationFolder
        The path of the folder in which all the .exe, .msi and .msu will be downloaded
        This parameter is not mandatory. The default value is C:\_OOS16SOURCES"
        You must never write a "\" at the end of this folder path
    .PARAMETER Language
        The language pack you want to download
        This parameter is not mandatory. You must enter a value formatted like en-us or fr-fr
        The languages packs managed are fr-fr, en-us, es-es and it-it
    .EXAMPLE
        .\OOS16_Download-PrerequisitesLP.ps1
        This will download Office Online Server 2016 prerequisistes in the folder C:\_OOS16SOURCES\Prerequisites
        This will download Office Online Server 2016 language pack in the folder D:\_OOS16SOURCES\Languages
    .EXAMPLE
        .\OOS16_Download-PrerequisitesLP.ps1 -XmlFilePath "OOS16DownloadConfiguration.xml" -DestinationFolder "D:\_oos16" -Language "fr-fr"
        This will download Office Online Server 2016 prerequisistes in the folder D:\_oos16\Prerequisites
        This will download Office Online Server 2016 language pack in the folder D:\_oos16\Languages
    .NOTES
        Author : Sylver SCHORGEN
        Blog : http://microsofttouch.fr/default/b/sylver
        Created : 09 dec. 2016
        @sylver_schorgen
#>


param (
    [Parameter(Mandatory=$false)]
    [string] $XmlFilePath = "OOS16DownloadConfiguration.xml",
    [Parameter(Mandatory=$false)]
    [string] $DestinationFolder = "C:\_OOS16SOURCES",
    [Parameter(Mandatory=$false)]
    [string] $Language = "fr-fr"
)


[xml]$Xml = Get-Content $XmlFilePath
$PrerequisitesFolder = $DestinationFolder + "\Prerequisites"
$LanguagePackFolder = $DestinationFolder + "\Languages"

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
    
    Write-Host " -- Folder $PrerequisitesFolder ..." -NoNewline
    
    if(!(Test-Path $PrerequisitesFolder)) {
        New-Item -Path $PrerequisitesFolder -ItemType Directory | Out-Null
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

# Function used to download Office Online 2016 prerequisites
function Download-OOS16Prerequisites {

    Write-Host "### DOWNLOADING OFFICE ONLINE SERVER 2016 PREREQUISITES ###"
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

# Function used to download Office Online Server 2016 language packs
function Download-OOS16LP
{
    
    Write-Host "### DOWNLOADING OFFICE ONLINE 2016 LANGUAGE PACK ###"
    
    foreach($LP in $Xml.Product.LanguagePacks.LanguagePack) {
        
        if($LP.Name -eq $Language) {
            $File = $LP.Url.Split('/')[-1]
            $FilePath = $LanguagePackFolder + "\" + $File
        
            if (!(Test-Path $FilePath)) {
                Try {
                    Write-Host " -- Downloading $File ..." -NoNewline
                    Start-BitsTransfer -Source $LP.Url -Destination "$LanguagePackFolder" -DisplayName "Downloading `'$file`' to $LanguagePackFolder" -Priority Foreground -Description "From $($LP.Url)..." -RetryInterval 60 -RetryTimeout 3600 -ErrorVariable err
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
Download-OOS16Prerequisites
Download-OOS16LP