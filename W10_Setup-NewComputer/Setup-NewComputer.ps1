########################################################################################################################################
#		
#		Name				: Setup-NewComputer.ps1
#		Description			: Script used to install my softwares and configure Windows 10 like I want to
#							  The functions used to configure Windows 10 are from Ali Robertson and his script reclaimWindows10.ps1
#							  I added a log part to all the functions in order to log all actions in a file. There is 1 log for
#							  software installations (software_installation.log) and 1 log for computer configuration 
#							  (computer_configuration.log). I use this script to setup my professional and personal computer as well
#							  as my W10 virtual machines.
#
#		Thanks to			: Ali Robertson and his script reclaimWindows10.ps1 (https://gist.github.com/alirobe/7f3b34ad89a159e6daa1)
#							  All the functions used in my script to configure Windows are from his script.
#							  His full script turns off some unnecessary Windows 10 telemetery, bloatware, & privacy things
#
#		Modified by			: Sylver SCHORGEN (contact [a] schorgen.com)
#		Last Modification	: 01-Aug-2018
#		Version				: 1.0
#
########################################################################################################################################


"********** SOFTWARE INSTALLATION LOG ********** `n" >> "software_installation.log"
"********** WINDOWS CONIGURATION LOG ********** `n" >> "windows_configuration.log"

Function Install-Software {
	# Bypass ExecutionPolicy and install Chocolatey if not installed
	if (!(Get-Command choco.exe -ErrorAction SilentlyContinue)) {
		Set-ExecutionPolicy Bypass -Scope Process -Force
		Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))

		" Installation of Chocolatey done `n" >> "software_installation.log"
	}
	
	# PDF reader
	choco install foxitreader -y
	" Installation of Foxit Reader done `n" >> "software_installation.log"

	# Adobe products
	choco install flashplayerplugin -y
	choco install flashplayeractivex -y
	" Installation of Adobe Flash Player done `n" >> "software_installation.log"

	# Browsers
	choco install googlechrome -y
	choco install firefox -y
	choco install adblockplus-firefox -y
	" Installation of Google Chrome done `n" >> "software_installation.log"
	" Installation of Mozilla Firefox done `n" >> "software_installation.log"
	" Installation of Adblock Plus for Firefox done `n" >> "software_installation.log"


	# Multimedia
	choco install vlc -y
	choco install silverlight -y
	choco install handbrake -y
	choco install sonos-controller -y
	choco install itunes -y
	choco install qbittorrent -y
	" Installation of VLC done `n" >> "software_installation.log"
	" Installation of Silverlight done `n" >> "software_installation.log"
	" Installation of Handbrake done `n" >> "software_installation.log"
	" Installation of Sonos Controller done `n" >> "software_installation.log"
	" Installation of iTunes done `n" >> "software_installation.log"
	" Installation of qBittorrent done `n" >> "software_installation.log"

	# Dev / scripting tools
	choco install git -y
	choco install github-desktop -y
	choco install vscode -y
	choco install vscode-powershell -y
	choco install vscode-mssql -y
	choco install notepadplusplus -y
	Install-PackageProvider -Name NuGet -Confirm:$false -Force
	Install-Module -Name AzureAD -Confirm:$false -Force
	Install-Module MSOnline -Confirm:$false -Force
	Install-Module SharePointPnPPowerShellOnline -Confirm:$false -Force
	## todo -> Install Microsoft Online Services Sign-in Assistant : https://go.microsoft.com/fwlink/p/?LinkId=286152
	" Installation of Git done `n" >> "software_installation.log"
	" Installation of GitHub done `n" >> "software_installation.log"
	" Installation of Visual Studio Code done `n" >> "software_installation.log"
	" Installation of Notepad++ done `n" >> "software_installation.log"
	" Installation of NuGet done `n" >> "software_installation.log"
	" Installation of AzureAD PowerShell Module done `n" >> "software_installation.log"
	" Installation of MSOnline PowerShell Module done `n" >> "software_installation.log"
	" Installation of SharePoint Online PnP PowerShell Module done `n" >> "software_installation.log"


	# Remote tools
	choco install kitty -y
	choco install rdm -y
	" Installation of Kitty done `n" >> "software_installation.log"
	" Installation of Remote Desktop Manager done `n" >> "software_installation.log"

	# Work tools
	choco install filezilla -y
	choco install teamviewer -y
	choco install keepass -y
	choco install winscp -y
	choco install winmerge -y
	" Installation of Filezilla done `n" >> "software_installation.log"
	" Installation of TeamViewer done `n" >> "software_installation.log"
	" Installation of Keepass done `n" >> "software_installation.log"
	" Installation of WinSCP done `n" >> "software_installation.log"
	" Installation of WinMerge done `n" >> "software_installation.log"

	# Office tools
	choco install 7zip -y
	choco install lightshot -y
	choco install evernote -y
	" Installation of 7Zip done `n" >> "software_installation.log"
	" Installation of LightShot done `n" >> "software_installation.log"
	" Installation of Evernote done `n" >> "software_installation.log"

	# Cloud tools
	choco install dropbox -y
	choco install microsoftazurestorageexplorer -y
	choco install microsoft-teams -y
	choco install slack -y
	" Installation of Dropbox done `n" >> "software_installation.log"
	" Installation of Microsoft Azure Storage Explorer done `n" >> "software_installation.log"
	" Installation of Microsoft Teams done `n" >> "software_installation.log"
	" Installation of Slack done `n" >> "software_installation.log"

	# Personal tools
	choco install rufus -y
	choco install grisbi -y
	choco install toggl -y
	choco install listary -y
	" Installation of Rufus done `n" >> "software_installation.log"
	" Installation of Grisbi done `n" >> "software_installation.log"
	" Installation of Toggl done `n" >> "software_installation.log"
	" Installation of Listary done `n" >> "software_installation.log"

	# Other tools
	choco install jre8 -y
	" Installation of JRE 8 done `n" >> "software_installation.log"

	# Office 365 Pro Plus
	# I didn't use Chocolatey for Office 365 Pro Plus because the package wasn't working properly

	$Url = "https://download.microsoft.com/download/2/7/A/27AF1BE6-DD20-4CB4-B154-EBAB8A7D4A7E/officedeploymenttool_10321.33602.exe"
	$Outpath = "setup_office.exe"
	$Path = (Get-Location).Path

	Invoke-WebRequest -Uri $Url -OutFile $Outpath

	$DownloadXML = '<Configuration> 
						<Add SourcePath="' + $Path + '" OfficeClientEdition="32"> 
						<Product ID="O365ProPlusRetail" > 
						<Language ID="en-us" />      
						</Product>  
						</Add> 
						</Configuration>'

	$InstallationXML = '<Configuration>
						<Add OfficeClientEdition="32" Channel="Monthly">
							<Product ID="O365ProPlusRetail">
								<Language ID="en-us"/>
								<ExcludeApp ID="Groove"/>
							</Product>
						</Add>
						<Updates Enabled="TRUE" Channel="Monthly"/>
						<Display Level="None" AcceptEULA="TRUE"/>
						<Property Name="FORCEAPPSHUTDOWN" Value="TRUE"/>
						<Property Name="SharedComputerLicensing" Value="0"/>
						<Property Name="PinIconsToTaskbar" Value="TRUE"/>
						</Configuration>'

	# Extracting Office 365 Pro Plus setup file
	.\setup_office.exe /extract:$Path /quiet

	# Exporting XML to files
	$DownloadXML > "download.xml"
	$InstallationXML > "install.xml"

	# I noted that we have to wail few seconds before launching the install (otherwise, the script generate an error)
	Start-Sleep -Seconds 10

	Write-Output "Downloading Office 365 Pro Plus latest version ..."
	.\setup.exe /download "download.xml"
	" Download of Office 365 Pro Plus done `n" >> "software_installation.log"

	Write-Output "Installing Office 365 Pro Plus latest version ..."
	.\setup.exe /configure "install.xml"
	" Installation of Office 365 Pro Plus done `n" >> "software_installation.log"

	Start-Sleep -Seconds 10

	# Removing the XML files, exe files and Office download folder
	Remove-Item .\configuration.xml
	Remove-Item .\download.xml
	Remove-Item .\install.xml
	Remove-Item .\Office -Recurse -Confirm:$false -Force
	Remove-Item .\setup_office.exe
	Remove-Item .\setup.exe
	" Removed all Office installation configuration and executable files `n" >> "software_installation.log"

	"`n ********** END OF SOFTWARE INSTALLATION LOG **********" >> "software_installation.log"
}


#### Configuring OS ####

# Function used to disable Windows 10 Hibernation
Function Disable-W10Hibernation {
	Set-ItemProperty -Path "HKLM:\System\CurrentControlSet\Control\Session Manager\Power" -Name "HibernteEnabled" -Type Dword -Value 0
	If (!(Test-Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FlyoutMenuSettings")) {
		New-Item -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FlyoutMenuSettings" | Out-Null
	}

	Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FlyoutMenuSettings" -Name "ShowHibernateOption" -Type Dword -Value 0

	" Windows 10 Hibernation disabled `n" >> "windows_configuration.xml"
}

# Function used to unpin all Start Menu tiles
Function Remove-W10StartMenuTiles {	
	If ([System.Environment]::OSVersion.Version.Build -ge 15063 -And [System.Environment]::OSVersion.Version.Build -le 16299) {
		Get-ChildItem -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\CloudStore\Store\Cache\DefaultAccount" -Include "*.group" -Recurse | ForEach-Object {
			$data = (Get-ItemProperty -Path "$($_.PsPath)\Current" -Name "Data").Data -Join ","
			$data = $data.Substring(0, $data.IndexOf(",0,202,30") + 9) + ",0,202,80,0,0"
			Set-ItemProperty -Path "$($_.PsPath)\Current" -Name "Data" -Type Binary -Value $data.Split(",")
		}
	} ElseIf ([System.Environment]::OSVersion.Version.Build -eq 17133) {
		$key = Get-ChildItem -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\CloudStore\Store\Cache\DefaultAccount" -Recurse | Where-Object { $_ -like "*start.tilegrid`$windows.data.curatedtilecollection.tilecollection\Current" }
		$data = (Get-ItemProperty -Path $key.PSPath -Name "Data").Data[0..25] + ([byte[]](202,50,0,226,44,1,1,0,0))
		Set-ItemProperty -Path $key.PSPath -Name "Data" -Type Binary -Value $data
	}

	" Default Start Menu tiles removed `n" >> "windows_configuration.xml"
}

# Function used to remove the Fax from Windows 10
Function Remove-W10FaxPrinter {
	Remove-Printer -Name "Fax" -ErrorAction SilentlyContinue
	" Default Fax Printer removed `n" >> "windows_configuration.xml"
}

# Function used to uninstall Microsoft XPS Document Writer
Function Uninstall-W10XPSPrinter {
	Disable-WindowsOptionalFeature -Online -FeatureName "Printing-XPSServices-Features" -NoRestart -WarningAction SilentlyContinue | Out-Null
	" Microsoft XPS Document Writer removed `n" >> "windows_configuration.xml"
}

# Function used to install Hyper-V - Not applicable to Home
Function Install-W10HyperV {
	If ((Get-WmiObject -Class "Win32_OperatingSystem").Caption -like "*Server*") {
		Install-WindowsFeature -Name "Hyper-V" -IncludeManagementTools -WarningAction SilentlyContinue | Out-Null
	} Else {
		Enable-WindowsOptionalFeature -Online -FeatureName "Microsoft-Hyper-V-All" -NoRestart -WarningAction SilentlyContinue | Out-Null
	}

	" Hyper-V installed `n" >> "windows_configuration.xml"
}

# Function used to uninstall Microsoft preinstalled Apps
Function Uninstall-W10PresinstalledApps {
	
	Get-AppxPackage "Microsoft.3DBuilder" | Remove-AppxPackage
	Get-AppxPackage "Microsoft.AppConnector" | Remove-AppxPackage
	Get-AppxPackage "Microsoft.BingFinance" | Remove-AppxPackage
	Get-AppxPackage "Microsoft.BingNews" | Remove-AppxPackage
	Get-AppxPackage "Microsoft.BingSports" | Remove-AppxPackage
	Get-AppxPackage "Microsoft.BingTranslator" | Remove-AppxPackage
	Get-AppxPackage "Microsoft.BingWeather" | Remove-AppxPackage
	Get-AppxPackage "Microsoft.CommsPhone" | Remove-AppxPackage
	Get-AppxPackage "Microsoft.ConnectivityStore" | Remove-AppxPackage
	Get-AppxPackage "Microsoft.GetHelp" | Remove-AppxPackage
	Get-AppxPackage "Microsoft.Getstarted" | Remove-AppxPackage
	Get-AppxPackage "Microsoft.Messaging" | Remove-AppxPackage
	Get-AppxPackage "Microsoft.Microsoft3DViewer" | Remove-AppxPackage
	Get-AppxPackage "Microsoft.MicrosoftOfficeHub" | Remove-AppxPackage
	Get-AppxPackage "Microsoft.MicrosoftPowerBIForWindows" | Remove-AppxPackage
	Get-AppxPackage "Microsoft.MicrosoftSolitaireCollection" | Remove-AppxPackage
	Get-AppxPackage "Microsoft.MicrosoftStickyNotes" | Remove-AppxPackage
	Get-AppxPackage "Microsoft.MinecraftUWP" | Remove-AppxPackage
	Get-AppxPackage "Microsoft.MSPaint" | Remove-AppxPackage
	Get-AppxPackage "Microsoft.NetworkSpeedTest" | Remove-AppxPackage
	Get-AppxPackage "Microsoft.Office.OneNote" | Remove-AppxPackage
	Get-AppxPackage "Microsoft.Office.Sway" | Remove-AppxPackage
	Get-AppxPackage "Microsoft.OneConnect" | Remove-AppxPackage
	Get-AppxPackage "Microsoft.People" | Remove-AppxPackage
	Get-AppxPackage "Microsoft.Print3D" | Remove-AppxPackage
	Get-AppxPackage "Microsoft.RemoteDesktop" | Remove-AppxPackage
	Get-AppxPackage "Microsoft.SkypeApp" | Remove-AppxPackage
	Get-AppxPackage "Microsoft.Wallet" | Remove-AppxPackage
	Get-AppxPackage "Microsoft.WindowsAlarms" | Remove-AppxPackage
	Get-AppxPackage "Microsoft.WindowsCamera" | Remove-AppxPackage
	Get-AppxPackage "microsoft.windowscommunicationsapps" | Remove-AppxPackage
	Get-AppxPackage "Microsoft.WindowsFeedbackHub" | Remove-AppxPackage
	Get-AppxPackage "Microsoft.WindowsMaps" | Remove-AppxPackage
	Get-AppxPackage "Microsoft.WindowsPhone" | Remove-AppxPackage
	Get-AppxPackage "Microsoft.Windows.Photos" | Remove-AppxPackage
	Get-AppxPackage "Microsoft.WindowsSoundRecorder" | Remove-AppxPackage
	Get-AppxPackage "Microsoft.ZuneMusic" | Remove-AppxPackage
	Get-AppxPackage "Microsoft.ZuneVideo" | Remove-AppxPackage
	Get-AppxPackage "Microsoft.XboxApp" | Remove-AppxPackage
	Get-AppxPackage "Microsoft.XboxIdentityProvider" | Remove-AppxPackage -ErrorAction SilentlyContinue
	Get-AppxPackage "Microsoft.XboxSpeechToTextOverlay" | Remove-AppxPackage
	Get-AppxPackage "Microsoft.XboxGameOverlay" | Remove-AppxPackage
	Get-AppxPackage "Microsoft.Xbox.TCUI" | Remove-AppxPackage
	
	If (!(Test-Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\GameDVR")) {
		New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\GameDVR" | Out-Null
	}

	Set-ItemProperty -Path "HKCU:\System\GameConfigStore" -Name "GameDVR_Enabled" -Type DWord -Value 0
	Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\GameDVR" -Name "AllowGameDVR" -Type DWord -Value 0

	" Microsoft preinstalled softwares uninstalled `n" >> "windows_configuration.xml"
}

# Function used to add "This PC" shortcut to Windows 10 desktop
Function Show-W10ThisPCOnDesktop {
	If (!(Test-Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\ClassicStartMenu")) {
		New-Item -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\ClassicStartMenu" -Force | Out-Null
	}

	Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\ClassicStartMenu" -Name "{20D04FE0-3AEA-1069-A2D8-08002B30309D}" -Type DWord -Value 0
	
	If (!(Test-Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\NewStartPanel")) {
		New-Item -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\NewStartPanel" -Force | Out-Null
	}
	
	Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\NewStartPanel" -Name "{20D04FE0-3AEA-1069-A2D8-08002B30309D}" -Type DWord -Value 0

	" This PC shortcut is on the Desktop `n" >> "windows_configuration.xml"
}

# Function used to change default Explorer view to "This PC"
Function Set-W10ExplorerToThisPC {
	Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "LaunchTo" -Type DWord -Value 1
	" Windows Explorer now starts on This PC view `n" >> "windows_configuration.xml"
}

# Function used to show hidden files in Windows explorer
Function Show-W10ExplorerHiddenFiles {
	Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "Hidden" -Type DWord -Value 1
	" Windows Explorer now shows hidden files `n" >> "windows_configuration.xml"
}

# Function used to hide recently and frequently used item shortcuts in Windows explorer
Function Hide-W10ExplorerRecentShortcuts {
	Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer" -Name "ShowRecent" -Type DWord -Value 0
	Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer" -Name "ShowFrequent" -Type DWord -Value 0

	" Windows Explorer does not show recently used items `n" >> "windows_configuration.xml"
}

# Function used to show known file extensions in Windows explorer
Function Show-W10ExplorerKnownExtensions {
	Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "HideFileExt" -Type DWord -Value 0
	" Windows Explorer now shows known extensions `n" >> "windows_configuration.xml"
}

# Function used to set Control Panel view to categories
Function Set-W10ControlPanelCategories {
	Remove-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\ControlPanel" -Name "StartupPage" -ErrorAction SilentlyContinue
	Remove-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\ControlPanel" -Name "AllItemsIconView" -ErrorAction SilentlyContinue

	" Control Panel is configured to Category view `n" >> "windows_configuration.xml"
}

# Function used to hide Search taskbar
Function Hide-W10TaskbarSearch {
	Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Search" -Name "SearchboxTaskbarMode" -Type DWord -Value 0
	" Search taskbar is now hidden `n" >> "windows_configuration.xml"
}


######## MAIN ########
#
#	Call functions
#
######################

Install-Software

Install-W10HyperV
Disable-W10Hibernation
Remove-W10StartMenuTiles
Remove-W10FaxPrinter
Uninstall-W10XPSPrinter
Uninstall-W10PresinstalledApps
Show-W10ThisPCOnDesktop
Show-W10ExplorerHiddenFiles
Show-W10ExplorerKnownExtensions
Hide-W10TaskbarSearch
Set-W10ExplorerToThisPC
Set-W10ControlPanelCategories
Hide-W10ExplorerRecentShortcuts

"********** END OF WINDOWS CONFIGURATION LOG **********" >> "windows_configuration.log"