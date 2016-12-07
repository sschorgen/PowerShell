<#
    .SYNOPSIS
        Script used to download SharePoint 2016 prerequisites, language pack, cumulative updates and services pack
    .DESCRIPTION
        Script used to download SharePoint 2016 prerequisites, lp, cu, sp based on a XML file that contains the link
    .PARAMETER XmlFilePath
        The path of the XML file containing the URLs for the prerequisites, CU and language pack
        This parameter is not mandatory. The default value is SP16DownloadConfiguration.xml
        The XML file must be in the same folder as SP16_Download-PrerequisitesCULP.ps1
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
        This parameter is not mandatory. The default value is November 2016
    .EXAMPLE
        .\SP16_Download-PrerequisitesCULP.ps1
        This will download SharePoint 2016 prerequisistes in the folder C:\_SP16SOURCES\Prerequisites
        This will download SharePoint 2016 November 2016 CU in the folder D:\_SP16SOURCES\CU
        This will download SharePoint 2016 language pack in the folder D:\_SP16SOURCES\Languages
    .EXAMPLE
        .\SP16_Download-PrerequisitesCULP.ps1 -XmlFilePath "SP16DownloadConfiguration.xml" -DestinationFolder "D:\_sp16" -Language "fr-fr" -CumulativeUpdate "November 2016"
        This will download SharePoint 2016 prerequisistes in the folder D:\_sp16\Prerequisites
        This will download SharePoint 2016 November 2016 CU in the folder D:\_sp16\CU
        This will download SharePoint 2016 prerequisistes in the folder D:\_sp16\Prerequisites
    .EXAMPLE
        .\SP16_Download-PrerequisitesCULP.ps1 -XmlFilePath "SP16DownloadConfiguration.xml" -DestinationFolder "D:\_sp16" -CumulativeUpdate "November 2016"
        This will download SharePoint 2016 prerequisistes in the folder D:\_sp16\Prerequisites
        This will download SharePoint 2016 November 2016 CU in the folder D:\_sp16\CU
        This will download SharePoint 2016 prerequisistes in the folder D:\_sp16\Prerequisites
    .NOTES
        Author : Sylver SCHORGEN
        Blog : http://microsofttouch.fr/default/b/sylver
        Created : 07 dec. 2016
        @sylver_schorgen
#>


param (
    [Parameter(Mandatory=$false)]
    [string] $XmlFilePath = "SP16DownloadConfiguration.xml",
    [Parameter(Mandatory=$false)]
    [string] $DestinationFolder = "C:\_SP16SOURCES",
    [Parameter(Mandatory=$false)]
    [string] $Language = "fr-fr",
    [Parameter(Mandatory=$false)]
    [string] $CumulativeUpdate = "November 2016"
)


[xml]$Xml = Get-Content $XmlFilePath
$PrerequisitesFolder = $DestinationFolder + "\Prerequisites"
$CUFolder = $DestinationFolder + "\CU"
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
                    
                    if($File -eq "WcfDataServices.exe") {
                        $WCFFilePath = $PrerequisitesFolder + "\" + "WcfDataServices56.exe"
                        $Item = Get-Item -Path $WCFFilePath -ErrorAction SilentlyContinue
                    }
                    if($item -eq $null) {
                        Write-Host " -- Downloading $File ..." -NoNewline
                        Start-BitsTransfer -Source $Prerequisite.Url -Destination "$PrerequisitesFolder" -DisplayName "Downloading `'$file`' to $PrerequisitesFolder" -Priority Foreground -Description "From $($Prerequisite.Url)..." -RetryInterval 60 -RetryTimeout 3600 -ErrorVariable err

                        if($File -eq "WcfDataServices.exe") {
                            Rename-Item -Path $FilePath -NewName "WcfDataServices56.exe"
                        }
                    }
                    
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