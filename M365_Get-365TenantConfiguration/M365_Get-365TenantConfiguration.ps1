<#
    .SYNOPSIS
        Script de recuperation de la configuration d'un tenant Office 365
    .DESCRIPTION
        Permet de recuperer l'integralite de la configuration d'un tenant Microsoft 365
        Ce script declenchera la creation d'un dossier nomme M365DSC_Temp_Export_Config a la racine du disque C
    .EXAMPLE
        .\M365_Get-365TenantConfiguration.ps1
        Cree le dossier M365DSC_Temp_Export_Config et recupere l'integralite de la configuration d'un tenant Microsoft 365
        Si c'est la premiere fois que vous executez le script, des droits sur le tenant vous seront demande
    .NOTES
        Author : Sylver SCHORGEN
        Company : SF2i
        Updated : 16 Jan. 2022
        @sylver_schorgen
#>

# Variables
$ConfigFolderPath = "C:\M365DSC_Temp_Export_Config\"
$Credential = Get-Credential

New-Item -ItemType Directory -Path $ConfigFolderPath

# Export de la configuration complete du tenant Office 365
Export-M365DSCConfiguration -Credential $Credential -Path $ConfigFolderPath