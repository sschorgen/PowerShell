
#
# Fonction permettant de récupérer le nom du tenant
#
function Get-O365TenantName {
    $Domains = Get-MSOLDomain | Select-Object Name,IsInitial

    foreach ($Domain in $Domains) {
        if ($Domain.IsInitial -eq $true) {
            return $Domain.Name
        }
    }
}

#
# Fonction permettant d'exporter toutes les licences
#
function Get-O365Licenses {

    Write-Host " -- Récupération de toutes les licences ... " -NoNewline

    $Licenses = Get-MsolAccountSku | Select-Object AccountSkuId,ActiveUnits,ConsumedUnits,WarningUnits

    $ReturnedLicenses = @()

    foreach ($License in $Licenses) {
        $TempLicense = New-Object -TypeName PSObject
        Add-Member -InputObject $TempLicense -MemberType NoteProperty -Name "Licence" -Value $License.AccountSkuId
        Add-Member -InputObject $TempLicense -MemberType NoteProperty -Name "Nb. de licences" -Value $License.ActiveUnits
        Add-Member -InputObject $TempLicense -MemberType NoteProperty -Name "Licences consommées" -Value $License.ConsumedUnits
        Add-Member -InputObject $TempLicense -MemberType NoteProperty -Name "Licences expirant dans moins d'un mois" -Value $License.WarningUnits

        $ReturnedLicenses += $TempLicense
    }

    Write-Host "OK !" -ForegroundColor Green

    $Tenant = Get-O365TenantName
    $CSVFileName = "00-reports\o365_" + $Tenant + "_licenses.csv"

    Write-Host "OK !" -ForegroundColor Green
    Write-Host " -- Export des licences vers le fichier CSV $CSVFileName  ... " -NoNewline

    $ReturnedLicenses | Export-Csv $CSVFileName -NoTypeInformation -Encoding Default

    Write-Host "OK !" -ForegroundColor Green
}

#
# Fonction permettant d'exporter tous les domaines
#
function Get-O365Domains {

    Write-Host " -- Récupération de tous les domaines ... " -NoNewline

    $Domains = Get-MsolDomain | Select-Object Name, Status, Authentication, VerificationMethod

    $ReturnedDomains = @()

    foreach ($Domain in $Domains) {
        $TempDomain = New-Object -TypeName PSObject
        Add-Member -InputObject $TempDomain -MemberType NoteProperty -Name "Domaine" -Value $Domain.Name
        Add-Member -InputObject $TempDomain -MemberType NoteProperty -Name "Statut" -Value $Domain.Status
        Add-Member -InputObject $TempDomain -MemberType NoteProperty -Name "Authentification" -Value $Domain.Authentication
        Add-Member -InputObject $TempDomain -MemberType NoteProperty -Name "Méthode de vérification" -Value $Domain.VerificationMethod

        $ReturnedDomains += $TempDomain
    }

    Write-Host "OK !" -ForegroundColor Green

    $Tenant = Get-O365TenantName
    $CSVFileName = "00-reports\o365_" + $Tenant + "_domains.csv"

    Write-Host "OK !" -ForegroundColor Green
    Write-Host " -- Export des domaines vers le fichier CSV $CSVFileName  ... " -NoNewline

    $ReturnedDomains | Export-Csv $CSVFileName -NoTypeInformation -Encoding Default

    Write-Host "OK !" -ForegroundColor Green
}

#
# Fonction exportant tous les utilisateurs Office 365 vers un fichier CSV avec les informations suivantes
#    - Nom
#    - Prénom
#    - SignInName
#    - UPN
#
# Le fichier CSV est exporté dans le dossier 01-reports
#
function Get-O365Users {
    
    Write-Host " -- Récupération de tous les utilisateurs ... " -NoNewline

    $Users = Get-MSOLUser | Select-Object Lastname,Firstname,Licenses,SignInName,UserPrincipalName,MSExchRecipientTypeDetails | Where-Object {$_.MSExchRecipientTypeDetails -eq 1}
    $ReturnedUsers = @()
    
    Write-Host "OK !" -ForegroundColor Green
    Write-Host " -- Traitement des licences ... " -NoNewline

    foreach ($User in $Users) {
        $Licenses = $null
        
        foreach ($License in $User.Licenses) {
            $Licenses += $License.AccountSku.SkuPartNumber + ";"
        }
        if ($Licenses.Substring($Licenses.Length-1) -eq ";") {
            $Licenses = $Licenses.Substring(0,$Licenses.Length - 1)
        }

        $TempUser = New-Object -TypeName PSObject
        Add-Member -InputObject $TempUser -MemberType NoteProperty -Name "Prénom" -Value $User.Firstname
        Add-Member -InputObject $TempUser -MemberType NoteProperty -Name "Nom" -Value $User.Lastname
        Add-Member -InputObject $TempUser -MemberType NoteProperty -Name "User Principal Name" -Value $User.UserPrincipalName
        Add-Member -InputObject $TempUser -MemberType NoteProperty -Name "Login" -Value $User.SignInName
        Add-Member -InputObject $TempUser -MemberType NoteProperty -Name "Licence" -Value $Licenses

        $ReturnedUsers += $TempUser
    }

    $Tenant = Get-O365TenantName
    $CSVFileName = "00-reports\o365_" + $Tenant + "_users.csv"

    Write-Host "OK !" -ForegroundColor Green
    Write-Host " -- Export des utilisateurs vers le fichier CSV $CSVFileName  ... " -NoNewline

    $ReturnedUsers | Export-Csv $CSVFileName -NoTypeInformation -Encoding Default

    Write-Host "OK !" -ForegroundColor Green
}

#
# Fonction affichant les informations d'un utilisateur à l'écran
#    - Nom
#    - Prénom
#    - SignInName
#    - Liste des licences attribuées
#    - UPN
#    - Liste des adresses mails
#    - Localisation de la BAL
#    - Téléphone fixe
#    - Téléphone portable
#    - Est-ce que l'utilisateur dispose d'une licence
#
# Le fichier CSV est exporté dans le dossier 01-reports
#
function Get-O365User {
    
    $User = Read-Host " Entrez le UPN (User Principal Name) de votre utilisateur "

    try {
        $TempUser = Get-MsolUser -UserPrincipalName $User -ErrorAction Stop | Select-Object Lastname,Firstname,Licenses,SignInName,UserPrincipalName,@{n="Mails";e={$_.ProxyAddresses}},UsageLocation,PhoneNumber,MobilePhone,IsLicensed

        foreach ($License in $TempUser.Licenses) {
            $Licenses += $License.AccountSku.SkuPartNumber + ";"
        }
        if ($Licenses.Substring($Licenses.Length-1) -eq ";") {
            $Licenses = $Licenses.Substring(0,$Licenses.Length - 1)
        }

        foreach ($Mail in $TempUser.Mails) {
            $Mails += $Mail + ";"
        }
        if ($Mails.Substring($Mails.Length-1) -eq ";") {
            $Mails = $Mails.Substring(0,$Mails.Length - 1)
        }

        $Mails = $Mails -replace "smtp:",""

        $ReturnedUser = New-Object -TypeName PSObject

        Add-Member -InputObject $ReturnedUser -MemberType NoteProperty -Name "Prénom" -Value $TempUser.Firstname
        Add-Member -InputObject $ReturnedUser -MemberType NoteProperty -Name "Nom" -Value $TempUser.Lastname
        Add-Member -InputObject $ReturnedUser -MemberType NoteProperty -Name "User Principal Name" -Value $TempUser.UserPrincipalName
        Add-Member -InputObject $ReturnedUser -MemberType NoteProperty -Name "Login" -Value $TempUser.SignInName
        Add-Member -InputObject $ReturnedUser -MemberType NoteProperty -Name "Licences" -Value $Licenses
        Add-Member -InputObject $ReturnedUser -MemberType NoteProperty -Name "Adresses mail" -Value $Mails
        Add-Member -InputObject $ReturnedUser -MemberType NoteProperty -Name "Téléphone fixe" -Value $TempUser.PhoneNumber
        Add-Member -InputObject $ReturnedUser -MemberType NoteProperty -Name "Téléphone portable" -Value $TempUser.MobilePhone
        Add-Member -InputObject $ReturnedUser -MemberType NoteProperty -Name "Lieu" -Value $TempUser.UsageLocation
        Add-Member -InputObject $ReturnedUser -MemberType NoteProperty -Name "Dispose d'une licence ?" -Value $TempUser.IsLicensed

        Write-Host ""
        Write-Host "--------------------------------------------------------------------------------"
        Write-Host ""
        $ReturnedUser
        Write-Host "--------------------------------------------------------------------------------"

    } 
    catch {
        Write-Host ""
        Write-Host " Le UPN entré n'existe pas !" -ForegroundColor Red
        Start-Sleep -Seconds 2
    }
}

#
# Fonction exportant tous les groupes (hors groupes Office 365) vers un fichier CSV avec les informations suivantes
#    - Nom
#    - Adresse mail
#    - Description
#    - Type de groupe
#    - Statut de la validation du groupe
#
# Le fichier CSV est exporté dans le dossier 01-reports
#
function Get-O365Groups {

     Write-Host " -- Récupération de tous les groupes ... " -NoNewline

    $Groups = Get-MsolGroup | Select-Object DisplayName,EmailAddress,Description,GroupType,ValidationStatus
    $ReturnedGroups = @()

    foreach ($Group in $Groups) {        

        $TempGroup = New-Object -TypeName PSObject
        Add-Member -InputObject $TempGroup -MemberType NoteProperty -Name "Nom" -Value $Group.DisplayName
        Add-Member -InputObject $TempGroup -MemberType NoteProperty -Name "Adresse mail" -Value $Group.EmailAddress
        Add-Member -InputObject $TempGroup -MemberType NoteProperty -Name "Description" -Value $Group.Description
        Add-Member -InputObject $TempGroup -MemberType NoteProperty -Name "Type" -Value $Group.GroupType
        Add-Member -InputObject $TempGroup -MemberType NoteProperty -Name "Statut" -Value $Group.ValidationStatus

        $ReturnedGroups += $TempGroup
    }

    $Tenant = Get-O365TenantName
    $CSVFileName = "00-reports\o365_" + $Tenant + "_groups.csv"

    Write-Host "OK !" -ForegroundColor Green
    Write-Host " -- Export des groupes vers le fichier CSV $CSVFileName  ... " -NoNewline

    $ReturnedGroups | Export-Csv $CSVFileName -NoTypeInformation -Encoding Default

    Write-Host "OK !" -ForegroundColor Green
}

#
# Fonction exportant les groupes ainsi que leurs membres dans un fichier CSV (hors groupe Office 365)
#    - Nom du groupe
#    - Adresse mail du membre
#    - Nom du membre
#    - Type de compte du membre (groupe ou utilisateur)
#
# Le fichier CSV est exporté dans le dossier 01-reports
#
function Get-O365GroupsWithMembers {

     Write-Host " -- Récupération de tous les groupes avec leurs membres ... " -NoNewline

    $Groups = Get-MsolGroup | Select-Object ObjectId,DisplayName,EmailAddress
    $ReturnedGroups = @()

    foreach ($Group in $Groups) {        

        $Members = Get-MsolGroupMember -GroupObjectId $Group.ObjectID | Select-Object DisplayName, EmailAddress, GroupMemberType

        foreach ($Member in $Members) {
            $TempGroup = New-Object -TypeName PSObject
            Add-Member -InputObject $TempGroup -MemberType NoteProperty -Name "Nom du groupe" -Value $Group.DisplayName
            Add-Member -InputObject $TempGroup -MemberType NoteProperty -Name "Email du groupe" -Value $Group.EmailAddress
            Add-Member -InputObject $TempGroup -MemberType NoteProperty -Name "Nom du membre" -Value $Member.DisplayName
            Add-Member -InputObject $TempGroup -MemberType NoteProperty -Name "Email du membre" -Value $Member.EmailAddress
            Add-Member -InputObject $TempGroup -MemberType NoteProperty -Name "Type de compte du membre" -Value $Member.GroupMemberType

            $ReturnedGroups += $TempGroup
        }
    }

    $Tenant = Get-O365TenantName
    $CSVFileName = "00-reports\o365_" + $Tenant + "_groups_with_members.csv"

    Write-Host "OK !" -ForegroundColor Green
    Write-Host " -- Export des groupes vers le fichier CSV $CSVFileName  ... " -NoNewline

    $ReturnedGroups | Export-Csv $CSVFileName -NoTypeInformation -Encoding Default

    Write-Host "OK !" -ForegroundColor Green

}

#
# Fonction affichant les informations d'un groupe à l'écran (hors groupe Office 365)
#    - Nom
#    - Adresse mail
#    - Description
#    - Type de groupe
#    - Statut de la validation du groupe
#
function Get-O365Group {

$Group = Read-Host " Entrez l'adresse mail de votre groupe "

    try {
        $TempGroup = Get-MsolGroup | Select-Object DisplayName,EmailAddress,Description,GroupType,ValidationStatus | Where-Object {$_.EmailAddress -eq $Group}
        
        if (($TempGroup -eq "") -or ($TempGroup -eq " ") -or ($TempGroup -eq $null)) {
            Write-Host ""
            Write-Host " Le nom de groupe entré n'existe pas !" -ForegroundColor Red
            Start-Sleep -Seconds 2
        }
        else {
            $ReturnedGroup = New-Object -TypeName PSObject

            Add-Member -InputObject $ReturnedGroup -MemberType NoteProperty -Name "Nom" -Value $TempGroup.DisplayName
            Add-Member -InputObject $ReturnedGroup -MemberType NoteProperty -Name "Adresse mail" -Value $TempGroup.EmailAddress
            Add-Member -InputObject $ReturnedGroup -MemberType NoteProperty -Name "Description" -Value $TempGroup.Description
            Add-Member -InputObject $ReturnedGroup -MemberType NoteProperty -Name "Type" -Value $TempGroup.GroupType
            Add-Member -InputObject $ReturnedGroup -MemberType NoteProperty -Name "Statut" -Value $TempGroup.ValidationStatus

            Write-Host ""
            Write-Host "--------------------------------------------------------------------------------"
            Write-Host ""
            $ReturnedGroup
            Write-Host "--------------------------------------------------------------------------------"
            
        }
    } 
    catch {
        Write-Host ""
        Write-Host " Le nom de groupe entré n'existe pas !" -ForegroundColor Red
        Start-Sleep -Seconds 2
    }
}

#
# Fonction affichant les informations d'un groupe à l'écran avec ses membres (hors groupe Office 365)
#    - Adresse mail du membre
#    - Nom du membre
#
function Get-O365GroupWithMembers {

$Group = Read-Host " Entrez l'adresse mail de votre groupe "

    try {
        $TempGroup = Get-MsolGroup | Select-Object ObjectId,EmailAddress,DisplayName | Where-Object {$_.EmailAddress -eq $Group}
        
        if (($TempGroup -eq "") -or ($TempGroup -eq " ") -or ($TempGroup -eq $null)) {
            Write-Host ""
            Write-Host " Le nom de groupe entré n'existe pas !" -ForegroundColor Red
            Start-Sleep -Seconds 2
        }
        else {
            $Members = Get-MsolGroupMember -GroupObjectId $TempGroup.ObjectID | Select-Object DisplayName, EmailAddress

            Write-Host ""
            Write-Host "--------------------------------------------------------------------------------"
            Write-Host ""

            foreach ($Member in $Members) {
                Write-Host " -- $($Member.DisplayName) - $($Member.EmailAddress)"
            }

            Write-Host ""
            Write-Host "--------------------------------------------------------------------------------"
            
        }
    } 
    catch {
        Write-Host ""
        Write-Host " Le nom de groupe entré n'existe pas !" -ForegroundColor Red
        Start-Sleep -Seconds 2
    }
}

#
# Fonction exportant les groupes Office 365 dans un fichier CSV
#    - Nom du groupe
#    - Adresse mail du groupe
#    - Description du group
#    - Type de groupe
#    - URL du site SharePoint
#    - URL de la bibliothèque de documents SharePoint
#    - URL du notebook SharePoint
#
# Le fichier CSV est exporté dans le dossier 01-reports
#
function Get-O365O365Groups {

     Write-Host " -- Récupération de tous les groupes Office 365 ... " -NoNewline

    $Groups = Get-UnifiedGroup | Select-Object DisplayName,PrimarySMTPAddress,Notes,SharePointSiteUrl,SharePointDocumentsUrl,SharePointNotebookUrl,GroupType
    $ReturnedGroups = @()

    foreach ($Group in $Groups) {        

        $TempGroup = New-Object -TypeName PSObject
        Add-Member -InputObject $TempGroup -MemberType NoteProperty -Name "Nom" -Value $Group.DisplayName
        Add-Member -InputObject $TempGroup -MemberType NoteProperty -Name "Adresse mail" -Value $Group.PrimarySMTPAddress
        Add-Member -InputObject $TempGroup -MemberType NoteProperty -Name "Description" -Value $Group.Notes
        Add-Member -InputObject $TempGroup -MemberType NoteProperty -Name "Type" -Value $Group.GroupType
        Add-Member -InputObject $TempGroup -MemberType NoteProperty -Name "URL site SharePoint" -Value $Group.SharePointSiteUrl
        Add-Member -InputObject $TempGroup -MemberType NoteProperty -Name "URL bibliothèque SharePoint" -Value $Group.SharePointSiteUrl
        Add-Member -InputObject $TempGroup -MemberType NoteProperty -Name "URL notebook SharePoint" -Value $Group.SharePointNotebookUrl

        $ReturnedGroups += $TempGroup
    }

    $Tenant = Get-O365TenantName
    $CSVFileName = "00-reports\o365_" + $Tenant + "_o365groups.csv"

    Write-Host "OK !" -ForegroundColor Green
    Write-Host " -- Export des groupes vers le fichier CSV $CSVFileName  ... " -NoNewline

    $ReturnedGroups | Export-Csv $CSVFileName -NoTypeInformation -Encoding Default

    Write-Host "OK !" -ForegroundColor Green
}

#
# Fonction exportant les groupes ainsi que leurs membres dans un fichier CSV (hors groupe Office 365)
#    - Nom du groupe
#    - Adresse mail du membre
#    - Nom du membre
#    - Type de compte du membre (groupe ou utilisateur)
#
# Le fichier CSV est exporté dans le dossier 01-reports
#
function Get-O365O365GroupsWithMembers {

     Write-Host " -- Récupération de tous les groupes Office 365 avec leurs membres ... " -NoNewline

    $Groups = Get-UnifiedGroup | Select-Object DisplayName,PrimarySMTPAddress,Notes
    $ReturnedGroups = @()

    foreach ($Group in $Groups) {        

        $Members = Get-UnifiedGroupLinks -Identity $Group.DisplayName -LinkType Members | Select-Object Name, PrimarySMTPAddress

        foreach ($Member in $Members) {
            $TempGroup = New-Object -TypeName PSObject
            Add-Member -InputObject $TempGroup -MemberType NoteProperty -Name "Nom du groupe" -Value $Group.DisplayName
            Add-Member -InputObject $TempGroup -MemberType NoteProperty -Name "Email du groupe" -Value $Group.PrimarySMTPAddress
            Add-Member -InputObject $TempGroup -MemberType NoteProperty -Name "Nom du membre" -Value $Member.Name
            Add-Member -InputObject $TempGroup -MemberType NoteProperty -Name "Email du membre" -Value $Member.PrimarySMTPAddress

            $ReturnedGroups += $TempGroup
        }
    }

    $Tenant = Get-O365TenantName
    $CSVFileName = "00-reports\o365_" + $Tenant + "_o365groups_with_members.csv"

    Write-Host "OK !" -ForegroundColor Green
    Write-Host " -- Export des groupes vers le fichier CSV $CSVFileName  ... " -NoNewline

    $ReturnedGroups | Export-Csv $CSVFileName -NoTypeInformation -Encoding Default

    Write-Host "OK !" -ForegroundColor Green

}

#
# Fonction affichant les informations d'un groupe Office 365 à l'écran
#    - Nom du groupe
#    - Adresse mail du groupe
#    - Description du groupe
#    - Type de groupe
#    - URL du site SharePoint
#    - URL de la bibliothèque de documents SharePoint
#    - URL du notebook SharePoint
#
function Get-O365O365Group {

$Group = Read-Host " Entrez l'adresse mail ou le nom de votre groupe Office 365 "

    try {
        $TempGroup = Get-UnifiedGroup -Identity $Group | Select-Object DisplayName,PrimarySMTPAddress,Notes,SharePointSiteUrl,SharePointDocumentsUrl,SharePointNotebookUrl
        
        if (($TempGroup -eq "") -or ($TempGroup -eq " ") -or ($TempGroup -eq $null)) {
            Write-Host ""
            Write-Host " Le nom de groupe entré n'existe pas !" -ForegroundColor Red
            Start-Sleep -Seconds 2
        }
        else {
            $ReturnedGroup = New-Object -TypeName PSObject

            Add-Member -InputObject $ReturnedGroup -MemberType NoteProperty -Name "Nom" -Value $TempGroup.DisplayName
            Add-Member -InputObject $ReturnedGroup -MemberType NoteProperty -Name "Adresse mail" -Value $TempGroup.PrimarySMTPAddress
            Add-Member -InputObject $ReturnedGroup -MemberType NoteProperty -Name "Description" -Value $TempGroup.Notes
            Add-Member -InputObject $ReturnedGroup -MemberType NoteProperty -Name "Adresse site SharePoint" -Value $TempGroup.SharePointSiteUrl
            Add-Member -InputObject $ReturnedGroup -MemberType NoteProperty -Name "Adresse bibliothèque SharePoint" -Value $TempGroup.SharePointDocumentsUrl
            Add-Member -InputObject $ReturnedGroup -MemberType NoteProperty -Name "Adresse notebook SharePoint" -Value $TempGroup.SharePointNotebookUrl

            Write-Host ""
            Write-Host "--------------------------------------------------------------------------------"
            Write-Host ""
            $ReturnedGroup
            Write-Host "--------------------------------------------------------------------------------"
            
        }
    } 
    catch {
        Write-Host ""
        Write-Host " Le nom de groupe entré n'existe pas !" -ForegroundColor Red
        Start-Sleep -Seconds 2
    }
}

#
# Fonction affichant les informations d'un groupe Office 365 à l'écran
#    - Nom du groupe
#    - Adresse mail du groupe
#    - Description du groupe
#    - Type de groupe
#    - URL du site SharePoint
#    - URL de la bibliothèque de documents SharePoint
#    - URL du notebook SharePoint
#
function Get-O365O365GroupWithMembers {

$Group = Read-Host " Entrez l'adresse mail ou le nom de votre groupe Office 365 "

    try {
        $TempGroup = Get-UnifiedGroup -Identity $Group | Select-Object DisplayName,PrimarySMTPAddress,Notes,SharePointSiteUrl,SharePointDocumentsUrl,SharePointNotebookUrl
        
        if (($TempGroup -eq "") -or ($TempGroup -eq " ") -or ($TempGroup -eq $null)) {
            Write-Host ""
            Write-Host " Le nom de groupe entré n'existe pas !" -ForegroundColor Red
            Start-Sleep -Seconds 2
        }
        else {
            $Members = Get-UnifiedGroupLinks -Identity $TempGroup.DisplayName -LinkType Members | Select-Object Name, PrimarySMTPAddress


            Write-Host ""
            Write-Host "--------------------------------------------------------------------------------"
            Write-Host ""

            foreach ($Member in $Members) {
                Write-Host " -- $($Member.Name) - $($Member.PrimarySMTPAddress)"
            }

            Write-Host ""
            Write-Host "--------------------------------------------------------------------------------"
        }
    } 
    catch {
        Write-Host ""
        Write-Host " Le nom de groupe entré n'existe pas !" -ForegroundColor Red
        Start-Sleep -Seconds 2
    }
}

#
# Fonction permettant de désactiver la possibilité de créer des groupes Office 365
#
function Disable-O365O365GroupCreation {
    Write-Host " -- Désactivation de la possibilité de créer des groupes Office 365 ... " -NoNewline

    Get-OwaMailboxPolicy | ? { $_.IsDefault -eq $true } | Set-OwaMailboxPolicy -GroupCreationEnabled $false

    Write-Host "OK ! " -ForegroundColor Green
}

#
# Fonction permettant d'activer la possibilité de créer des groupes Office 365
#
function Enable-O365O365GroupCreation {
    Write-Host " -- Activation de la possibilité de créer des groupes Office 365 ... " -NoNewline

    Get-OwaMailboxPolicy | ? { $_.IsDefault -eq $true } | Set-OwaMailboxPolicy -GroupCreationEnabled $true

    Write-Host "OK ! " -ForegroundColor Green
}