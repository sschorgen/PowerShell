
#
# Menu d'accueil proposant de s'authentifier ou de quitter le programme
#
function Start-Menu  {
    
    Write-Host ""
    Write-Host " Office 365 Management Framework - Menu " -ForegroundColor Yellow
    Write-Host "----------------------------------------" -ForegroundColor Yellow
    Write-Host " 1 - Entrer vos credentials Office 365" -ForegroundColor Yellow
    Write-Host " 2 - Quitter" -ForegroundColor Yellow
    Write-Host ""
   
    $Choice = Read-Host " Entrer votre choix "
    
    Write-Host ""

    if ($Choice -eq 1) {
        Get-O365Credentials
    }
    elseif ($Choice -eq 2) {
        Exit
    }
    else {
        Start-Menu
    }
}

#
# Menu général Office 365 proposant les catégories gérées par ce script
#
function Start-O365Menu  {
    
    Write-Host ""
    Write-Host " Office 365 Management Framework - Menu Principal " -ForegroundColor Yellow
    Write-Host "--------------------------------------------------" -ForegroundColor Yellow
    Write-Host " 1 - Utilisateurs & Licences" -ForegroundColor Yellow
    <#Write-Host " 2 - Exchange Online" -ForegroundColor Yellow
    Write-Host " 3 - Statistiques" -ForegroundColor Yellow#>
    Write-Host " 99 - Quitter" -ForegroundColor Yellow
    Write-Host ""
   
    $Choice = Read-Host " Entrer votre choix "
    
    Write-Host ""

    if ($Choice -eq 1) {
        Start-O365UserMenu
    }
    <#elseif ($Choice -eq 2) {
        Start-O365ExchangeMenu
    }
    elseif ($Choice -eq 3) {
        Start-O365StatisticsMenu
    }#>
    elseif ($Choice -eq 99) {
        Exit-Program
    }
    else {
        Start-O365Menu
    }
}

#
# Menu Office 365 utilisateurs et licences
#
function Start-O365UserMenu  {

    Write-Host ""
    Write-Host " Office 365 Management Framework - Menu Utilisateurs & Licences " -ForegroundColor Yellow
    Write-Host "----------------------------------------------------------------" -ForegroundColor Yellow
    Write-Host " 0 - Retourner au menu principal" -ForegroundColor Yellow
    Write-Host " 1 - Exporter les utilisateurs vers un fichier CSV" -ForegroundColor Yellow
    Write-Host " 2 - Consulter un utilisateur" -ForegroundColor Yellow
    Write-Host " 3 - Exporter tous les groupes" -ForegroundColor Yellow
    Write-Host " 4 - Exporter tous les groupes avec leurs membres" -ForegroundColor Yellow
    Write-Host " 5 - Exporter tous les groupe Office 365" -ForegroundColor Yellow
    Write-Host " 6 - Exporter tous les groupes Office 365 avec leurs membres" -ForegroundColor Yellow
    Write-Host " 7 - Visualiser un groupe" -ForegroundColor Yellow
    Write-Host " 8 - Visualiser les membres d'un groupe" -ForegroundColor Yellow
    Write-Host " 9 - Visualiser un groupe Office 365" -ForegroundColor Yellow
    Write-Host "10 - Visualiser les membres d'un groupe Office 365" -ForegroundColor Yellow
    Write-Host "11 - Désactiver la possibilité de créer des groupes Office 365" -ForegroundColor Yellow
    Write-Host "12 - Activer la possibilité de créer des groupes Office 365" -ForegroundColor Yellow
    Write-Host "13 - Exporter les licences du tenant dans un fichier CSV" -ForegroundColor Yellow
    Write-Host "14 - Exporter les domaines associés au tenant vers un fichier CSV" -ForegroundColor Yellow
    Write-Host "99 - Quitter" -ForegroundColor Yellow
    Write-Host ""
   
    $Choice = Read-Host " Entrer votre choix "
    
    Write-Host ""

    if ($Choice -eq 0) {
        Start-O365Menu
    }
    elseif ($Choice -eq 1) {
        Get-O365Users
        Start-O365UserMenu
    }
    elseif ($Choice -eq 2) {
        Get-O365User
        Start-O365UserMenu
    }
    elseif ($Choice -eq 3) {
        Get-O365Groups
        Start-O365UserMenu
    }
    elseif ($Choice -eq 4) {
        Get-O365GroupsWithMembers
        Start-O365UserMenu
    }
    elseif ($Choice -eq 5) {
        Get-O365O365Groups
        Start-O365UserMenu
    }
    elseif ($Choice -eq 6) {
        Get-O365O365GroupsWithMembers
        Start-O365UserMenu
    }
    elseif ($Choice -eq 7) {
        Get-O365Group
        Start-O365UserMenu
    }
    elseif ($Choice -eq 8) {
        Get-O365GroupWithMembers
        Start-O365UserMenu
    }
    elseif ($Choice -eq 9) {
        Get-O365O365Group
        Start-O365UserMenu
    }
    elseif ($Choice -eq 10) {
        Get-O365O365GroupWithMembers
        Start-O365UserMenu
    }
    elseif ($Choice -eq 11) {
        Disable-O365O365GroupCreation
        Start-O365UserMenu
    }
    elseif ($Choice -eq 12) {
        Enable-O365O365GroupCreation
        Start-O365UserMenu
    }
    elseif ($Choice -eq 13) {
        Get-O365Licenses
        Start-O365UserMenu
    }
    elseif ($Choice -eq 14) {
        Get-O365Domains
        Start-O365UserMenu
    }
    elseif ($Choice -eq 99) {
        Exit-Program
    }
    else {
        Start-O365UserMenu
    }

}

#
# Menu Exchange Online
#
function Start-O365ExchangeMenu  {

    Write-Host ""
    Write-Host " Office 365 Management Framework - Menu Exchange Online " -ForegroundColor Yellow
    Write-Host "--------------------------------------------------------" -ForegroundColor Yellow
    Write-Host " 0 - Retourner au menu principal" -ForegroundColor Yellow
    Write-Host " 1 - Exporter les boîtes aux lettres utilisateurs" -ForegroundColor Yellow
    Write-Host " 2 - Consulter la boîte aux lettres d'un utilisateur" -ForegroundColor Yellow
    Write-Host " 3 - Exporter toues les listes de distribution" -ForegroundColor Yellow
    Write-Host " 4 - Exporter toutes les listes de distribution avec leurs membres" -ForegroundColor Yellow
    Write-Host " 5 - Visualiser une liste de distribution" -ForegroundColor Yellow
    Write-Host " 6 - Visualiser une liste de distribution avec ses membres" -ForegroundColor Yellow
    Write-Host " 7 - Exporter toutes les boîtes aux lettres partagées" -ForegroundColor Yellow
    Write-Host " 8 - Exporter toues les boîtes aux lettres partagées avec leur appartenance" -ForegroundColor Yellow
    Write-Host " 9 - Visualiser une boîte aux lettres partagée" -ForegroundColor Yellow
    Write-Host "10 - Visualiser une boîte aux lettres partagée avec son appartenance" -ForegroundColor Yellow
    Write-Host "11 - Désactiver la boîte aux lettres prioritaires pour tous les utilisateurs" -ForegroundColor Yellow
    Write-Host "12 - Désactiver la boîte aux lettres prioritaires pour un utilisateur" -ForegroundColor Yellow
    Write-Host "13 - Désactiver 'Clutter Mailbox' pour tous les utilisateurs" -ForegroundColor Yellow
    Write-Host "14 - Désactiver 'Clutter Mailbox' pour un utilisateur" -ForegroundColor Yellow
    Write-Host "99 - Quitter" -ForegroundColor Yellow
    Write-Host ""
   
    $Choice = Read-Host " Entrer votre choix "
    
    Write-Host ""

    if ($Choice -eq 0) {
        Start-O365Menu
    }
    elseif ($Choice -eq 2) {
        # Code ici
    }
    elseif ($Choice -eq 3) {
        # Code ici
    }
    elseif ($Choice -eq 4) {
        # Code ici
    }
    elseif ($Choice -eq 5) {
        # Code ici
    }
    elseif ($Choice -eq 6) {
        # Code ici
    }
    elseif ($Choice -eq 7) {
        # Code ici
    }
    elseif ($Choice -eq 8) {
        # Code ici
    }
    elseif ($Choice -eq 9) {
        # Code ici
    }
    elseif ($Choice -eq 10) {
        # Code ici
    }
    elseif ($Choice -eq 11) {
        # Code ici
    }
    elseif ($Choice -eq 12) {
        # Code ici
    }
    elseif ($Choice -eq 13) {
        # Code ici
    }
    elseif ($Choice -eq 14) {
        # Code ici
    }
    elseif ($Choice -eq 15) {
        Exit-Program
    }
    else {
        Start-O365ExchangeMenu
    }

}

#
# Menu Office 365 statistique
#
function Start-O365StatisticsMenu  {
    
    Write-Host ""
    Write-Host " Office 365 Management Framework - Menu Statistiques " -ForegroundColor Yellow
    Write-Host "-----------------------------------------------------" -ForegroundColor Yellow
    Write-Host " 0 - Retourner au menu principal" -ForegroundColor Yellow
    Write-Host " 1 - Afficher la totalité des mails envoyés / reçus pour tous les utilisateurs" -ForegroundColor Yellow
    Write-Host " 2 - Exporter les mails envoyés / reçus pour tous les utilisateurs" -ForegroundColor Yellow
    Write-Host " 3 - Afficher les mails envoyés / reçus pour un utilisateur" -ForegroundColor Yellow
    Write-Host " 4 - Quitter" -ForegroundColor Yellow
    Write-Host ""

    $Choice = Read-Host " Entrer votre choix "
    
    Write-Host ""

    if ($Choice -eq 0) {
        Start-O365Menu
    }
    elseif ($Choice -eq 2) {
        # Code ici
    }
    elseif ($Choice -eq 3) {
        # Code ici
    }
    elseif ($Choice -eq 4) {
        Exit-Program
    }
    else {
        Start-O365StatisticsMenu
    }
}

function Get-O365Credentials  {
    $O365Credentials = Get-Credential

    try {
        Connect-MsolService -Credential $O365Credentials -ErrorAction Stop
        $Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://ps.outlook.com/powershell -Credential $O365Credentials -Authentication Basic -AllowRedirection  -ErrorAction Stop
        Import-PSSession $Session -AllowClobber -ErrorAction Stop | Out-Null

        Start-O365Menu

    }
    catch {
        Write-Host ""
        Write-Host "Erreur de login / mot de passe !" -ForegroundColor Red
        Start-Sleep -Seconds 2
        Get-PSSession | Remove-PSSession
        Start-Menu
    }
}

function Exit-Program {
    Get-PSSession | Remove-PSSession
    Exit
}

##############################
###         MAIN           ###
##############################

$CurrentPath = (Get-Item -Path ".\" -Verbose).FullName

$UsersLicensesScript = $CurrentPath + "\o365_users_licenses.ps1"
$ExchangeScript = $CurrentPath + "\o365_exchange.ps1"
$StatisticScript = $CurrentPath + "\o365_statistics.ps1"

. $UsersLicensesScript
. $ExchangeScript
. $StatisticScript

Start-Menu