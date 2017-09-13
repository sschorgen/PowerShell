####################################################################
#
# SCRIPT USED TO MIGRATE USER AND GROUPS FROM ONE DOMAIN TO ANOTHER
#
# CSV file format :
#   oldDomain,newDomain
#   OLD_DOMAIN\JDoe;NEW_DOMAIN\John.Doe
#   OLD_DOMAIN\Group;NEW_DOMAIN\New_Group
#
####################################################################

<#
    .SYNOPSIS
        Script used to migrate SharePoint users and groups from one domain to another one
    .DESCRIPTION
        Script used to migrate SharePoint users and groups from one domain to another one
    .PARAMETER UserMappingsCSV
        Specify the path of the CSV file containing your users from both domains
    .PARAMETER gGoupMappingsCSV
        Specify the path of the CSV file containing your groups from both domains
    .EXAMPLE
        .\SP10_Migrate-SPUserAndGroupFromDomain.ps1 -UserMappingsCSV "D:\Scripts\users_to_migrate.csv" - GroupMappingsCSV "D:\Scripts\groups_to_migrate.csv"
        This will migrate all users in SharePoint as entered in the CSV file
    .NOTES
        Author : Sylver SCHORGEN
        Blog : http://microsofttouch.fr/default/b/sylver
        Created : 13 sept. 2017
        @sylver_schorgen
#>

Param(
    [Parameter(Mandatory=$true)]
    [string]$userMappingsCSV,
    [Parameter(Mandatory=$true)]
    [string]$groupMappingsCSV
)

#
# VARIABLES
#

Write-Host "VARIABLES CONFIGURATION ..." -NoNewLine

$farm = Get-SPFarm
$Groups = Import-Csv $groupMappingsCSV -Delimiter ";"
$Users = Import-Csv $userMappingsCSV -Delimiter ";"

Write-Host " OK !" -ForegroundColor Green
Write-Host ""
Write-Host "##### STARTING GROUPS MIGRATION #####"
Write-Host ""

ForEach($Group in $Groups) {
    Write-Host " --- MIGRATING GROUP " $Group.oldDomain "-->" $Group.newDomain -ForegroundColor Yellow -NoNewLine
    $farm.MigrateGroup($Group.oldDomain, $Group.newDomain) 
    Write-Host " OK !" -ForegroundColor Green
}

Write-Host ""
Write-Host "##### GROUPS MIGRATION DONE #####" -ForegroundColor Green
Write-Host "##### STARTING USERS MIGRATION #####"
Write-Host ""
Write-Host ""

ForEach($User in $Users) {
    Write-Host " --- MIGRATING USER " $User.oldDomain "-->" $User.newDomain -ForegroundColor Yellow -NoNewLine
    $farm.MigrateUserAccount($User.oldDomain, $User.newDomain, $false) 
    Write-Host " OK !" -ForegroundColor Green
}

Write-Host ""
Write-Host "##### USERS MIGRATION DONE #####" -ForegroundColor Green