<#
    .SYNOPSIS
        Get all AD objects stored in AD Group
    .DESCRIPTION
        Get a list of all AD objects stored in AD Group
    .PARAMETER LogFilePath
        Specify your log file path. This path must end with a "\"
    .EXAMPLE
        .\AD_Get-ADUserByGroup.ps1 -LogFilePath "C:\Logs\"
        This will create a new log file containing all AD Objects by AD Groups
    .NOTES
        Author : Sylver SCHORGEN
        Blog : http://microsofttouch.fr/default/b/sylver
        Created : 25 feb. 2015
        @sylver_schorgen
#>


Param(
    [Parameter(Mandatory=$true)]
    [string]$LogFilePath
)


# Setting up log file and Groups variables
Write-Host
Write-Host
Write-Host "Setting up initial variables ... " -NoNewLine

$LogTime = Get-Date -Format "yyyyMMdd_hhmmss - "
$LogFileName = "AD Users by Group.log"
$LogFile = $LogFilePath + $LogTime + $LogFileName
$Groups = Get-ADGroup -Filter "*"

Write-Host "Ok !" -ForeGroundColor Green
Write-Host
Write-Host
Write-Host "Getting all AD Users by AD Groups ..."
Write-Host

# Getting all AD Groups and writing them in a file and on the console
foreach ($Group in $Groups) {
   
    Write-Host
    Write-Host " Group : $($Group.Name)"
	
    Write-Output "Group : $($Group.Name)" | Out-File $LogFile -Append
	
    # Getting all Members of an AD Group and writing them in a file and on the console
    $Members = Get-ADGroupMember $($Group.Name)
	
    Foreach($Member in $Members) {

		if($Member.ObjectClass -eq "user") {
			
            # Getting account status (Enable ou Disable)
            $user = Get-ADUser $Member -Properties enabled
            
            if ($user.enabled -eq $True) {
                Write-Output " * User : $($user.Name) --> Enable" | Out-File $LogFile -Append
                Write-Host " * User : $($user.Name) --> Enable"
            }
            else {
                Write-Output " * $($user.Name) --> Disable" | Out-File $LogFile -Append
                Write-Host " * $($user.Name) --> Disable"
            }
		}
        elseif($Member.ObjectClass -eq "group") {
            $NestedGroup = Get-ADGroup $Member
            Write-Output " * Group : $($NestedGroup.Name)" | Out-File $LogFile -Append
            Write-Host " * Group : $($NestedGroup.Name)"
        }
        elseif($Members.ObjectClass -eq "computer") {
            $Computer = Get-ADComputer $Member
            Write-Output " * Computer : $($Computer.Name)" | Out-File $LogFile -Append
            Write-Host " * Computer : $($Computer.Name)"
        }

	} # /Foreach Members

    Write-Host
    Write-Output "" | Out-File $LogFile -Append
}  # /Foreach Groups

Write-Host
Write-Host
Write-Host "Done !" -ForeGroundColor Green
Write-Host
