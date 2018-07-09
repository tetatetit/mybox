# Description: Boxstarter Script
# Author: Jess Frazelle <jess@linux.com> + my modifications
#
# Install boxstarter:
# 	. { iwr -useb http://boxstarter.org/bootstrapper.ps1 } | iex; get-boxstarter -Force
#
# You might need to set: Set-ExecutionPolicy RemoteSigned
#
# NOTE/WARNING BEFORE RUNNING SCRIPT:
# On Windoes 10 Enterprise 1803 (at least) we need in gpedit.msc in 
# "Computer Configuration\Administrative Templates\Windows Components\Windows Update"
# to set ANY (NO MATTER WHAT) item as configured, in order to get Windows Update policies
# configured in this script actually applied and work (otherwise they don't for some reason
# while e.g. Windows Defender policies are applied and work successfuly configured same way)
#
# Run this boxstarter by calling the following from an **elevated** command-prompt:
# 	start http://boxstarter.org/package/nr/url?https://raw.githubusercontent.com/tetatetit/mybox/master/initial.ps1
# OR
# 	Install-BoxstarterPackage -PackageName https://raw.githubusercontent.com/tetatetit/mybox/master/initial.ps1
#
# Learn more: http://boxstarter.org/Learn/WebLauncher

#---- TEMPORARY ---
#Disable-UAC

#$Boxstarter.RebootOk = $true # Allow reboots?
#$Boxstarter.NoPassword = $false # Is this a machine with no login password?
#$Boxstarter.AutoLogin = $true # Save my password securely and auto-login after a reboot
$Password = Read-Host "Enter a Password:" -AsSecureString
 
Update-ExecutionPolicy Unrestricted
#--- Windows Settings ---

# Disable system restore
Disable-ComputerRestore -Drive "C:\"

# Disable windows defender
Set-MpPreference -DisableRealtimeMonitoring $true
$DefenderPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender"
New-Item -Path $DefenderPath -Force
Set-ItemProperty -Path $DefenderPath -Name DisableAntiSpyware -Type DWord -Value 1 -Force
Set-ItemProperty -Path $DefenderPath -Name ServiceKeepAlive -Type DWord -Value 0 -Force
New-Item -Path "$DefenderPath\Real-Time Protection" -Force
Set-ItemProperty -Path "$DefenderPath\Real-Time Protection" -Name DisableRealtimeMonitoring -Type DWord -Value 1 -Force
Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\StartupApproved\Run" -Name "SecurityHealth" -Value ([byte[]]("07,00,00,00,d6,0e,8d,7b,ea,f5,d3,01".Split(',') | % { "0x$_"}))

# Disable Remote Assistance
Set-ItemProperty -Path  "HKLM:\SYSTEM\CurrentControlSet\Control\Remote Assistance" -Name "fAllowToGetHelp" -Type DWord -Value 0 -Force 
Enable-RemoteDesktop -DoNotRequireUserLevelAuthentication

function configure-updates() {
# Set Windows Update to:
# * Notify before download and install
# * Semi-Annual Channel
# * Defer features update to max possible 365 (until they a well tested)
#gpupdate /force /target:computer
$WindowsUpdatePath = "HKLM:SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate"
New-Item -Path $WindowsUpdatePath -Force
Set-ItemProperty -Path $WindowsUpdatePath -Name DeferFeatureUpdates -Type DWord -Value 1 -Force
Set-ItemProperty -Path $WindowsUpdatePath -Name BranchReadinessLevel -Type DWord -Value 32 -Force
Set-ItemProperty -Path $WindowsUpdatePath -Name DeferFeatureUpdatesPeriodInDays -Type DWord -Value 365 -Force
#Set-ItemProperty -Path $WindowsUpdatePath -Name PauseFeatureUpdatesStartTime -Value ""
Set-ItemProperty -Path $WindowsUpdatePath -Name ManagePreviewBuilds -Type DWord -Value 1 -Force
Set-ItemProperty -Path $WindowsUpdatePath -Name ManagePreviewBuildsPolicyValue -Type DWord -Value 0 -Force
#Set-ItemProperty -Path $WindowsUpdatePath -Name DeferQualityUpdates -Type DWord -Value 0 -Force
#Set-ItemProperty -Path $WindowsUpdatePath -Name DeferQualityUpdatesPeriodInDays -Type DWord -Value 0 -Force
#Set-ItemProperty -Path $WindowsUpdatePath -Name PauseQualityUpdatesStartTime -Value ""
New-Item -Path "$WindowsUpdatePath\AU" -Force
Set-ItemProperty -Path "$WindowsUpdatePath\AU" -Name NoAutoUpdate -Type DWord -Value 0 -Force
Set-ItemProperty -Path "$WindowsUpdatePath\AU" -Name AllowMUUpdateService -Type DWord -Value 1 -Force
Set-ItemProperty -Path "$WindowsUpdatePath\AU" -Name AUOptions -Type DWord -Value 2 -Force
Set-ItemProperty -Path "$WindowsUpdatePath\AU" -Name IncludeRecommendedUpdates -Type DWord -Value 1 -Force
Set-ItemProperty -Path "$WindowsUpdatePath\AU" -Name NoAutoRebootWithLoggedOnUsers -Type DWord -Value 1 -Force
#Set-ItemProperty -Path "$WindowsUpdatePath\AU" -Name ScheduledInstallDay -Type DWord -Value 0 -Force
#Set-ItemProperty -Path "$WindowsUpdatePath\AU" -Name ScheduledInstallTime -Type DWord -Value 3 -Force
#Set-ItemProperty -Path "$WindowsUpdatePath\AU" -Name ScheduledInstallEveryWeek -Type DWord -Value 1 -Force
#gpupdate /force /target:computer
}

# Disable Cortana
$WindowsSearchPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search"
New-Item -Path $WindowsSearchPath -Force
Set-ItemProperty -Path  "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search" -Name "AllowCortana" -Type DWord -Value 0 -Force 

# Disable Automatic Maintenance
Set-ItemProperty -Path  "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Schedule\Maintenance" -Name "MaintenanceDisabled" -Type DWord -Value 1 -Force 

# Disable Background Apps
Set-ItemProperty -Path  "HKCU:\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications" -Name "GlobalUserDisabled" -Type DWord -Value 1 -Force 
#Set-ItemProperty -Path  "HKLM:Software\Policies\Microsoft\Windows\AppPrivacy" -Name "LetAppsRunInBackground" -Type DWord -Value 2 -Force 

# Disable Smart Screen
Set-ItemProperty -Path  "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System" -Name "EnableSmartScreen" -Type DWord -Value 0 -Force 


# Never sleep
powercfg -change standby-timeout-ac 0
powercfg -change standby-timeout-dc 0
powercfg -change hibernate-timeout-ac 0
powercfg -change hibernate-timeout-dc 0

Disable-BingSearch
Disable-GameBarTips

Set-WindowsExplorerOptions -EnableShowFileExtensions
Set-TaskbarOptions -AlwaysShowIconsOn

# --- Uninstall crapware ---

# Uinstall OneDrive (to install older v17 one)
taskkill /f /im OneDrive.exe
C:\Windows\SysWOW64\OneDriveSetup.exe /uninstall

$AppsToRemove = (
    "*Microsoft.3DBuilder*",
    "*Microsoft.WindowsAlarms*",
    "*Autodesk*",
    "*Microsoft.BingFinance*", "*Microsoft.BingNews*", "*Microsoft.BingSports*", "*Microsoft.BingWeather*",
    "*BubbleWitch*",
    "*king.com.CandyCrush*",
    "*Microsoft.CommsPhone*",
    "*Dell*",
    "*Dropbox*",
    "*Facebook*",
    "*Microsoft.WindowsFeedbackHub*",
    "*Microsoft.Getstarted*",
    "*Keeper*",
    "*microsoft.windowscommunicationsapps*", # Mail & Calendar
    "*Microsoft.WindowsMaps*",
    "*MarchofEmpires*",
    "*McAfee*",
    "*Microsoft.Messaging*",
    "*Minecraft*",
    "*Netflix*",
    "*Microsoft.MicrosoftOfficeHub*",
    "*Microsoft.OneConnect*",
    "*Microsoft.Office.OneNote*",
    "*Microsoft.People*",
    "*Microsoft.WindowsPhone*",
    "*Microsoft.Windows.Photos*",
    "*Plex*",
    "*Microsoft.SkypeApp*", # Metro version
    "*Microsoft.WindowsSoundRecorder*",
    "*Solitaire*",
    "*Microsoft.MicrosoftStickyNotes*",
    "*Microsoft.Office.Sway*",
    "*Twitter*",
    #"*Microsoft.XboxApp*", "*Microsoft.XboxGame*", "*Microsoft.XboxIdentityProvider*",
    "*Microsoft.Xbox*", # All Xbox crapware
    "*Microsoft.ZuneMusic*", "*Microsoft.ZuneVideo*",
    "*AdobeSystemsIncorporated.AdobePhotoshopExpress*",
    "*Microsoft.Print3D*", "*Microsoft.3DBuilder*", "*Microsoft.Microsoft3DViewer*",
    "*Microsoft.WindowsCalculator*",
    "*Microsoft.WindowsCamera*",
    "*Microsoft.MSPaint*",
    "*Microsoft.Windows.Cortana*"
)
foreach($app in $AppsToRemove) {
	Get-AppxPackage $app | Remove-AppxPackage
	Get-AppxProvisionedPackage -Online | Where-Object {$_.PackageName -like $app} | Remove-AppxProvisionedPackage -Online
}

# Uninstall McAfee Security App
$mcafee = gci "HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall" | foreach { gp $_.PSPath } | ? { $_ -match "McAfee Security" } | select UninstallString
if ($mcafee) {
	$mcafee = $mcafee.UninstallString -Replace "C:\Program Files\McAfee\MSC\mcuihost.exe",""
	Write "Uninstalling McAfee..."
	start-process "C:\Program Files\McAfee\MSC\mcuihost.exe" -arg "$mcafee" -Wait
}

# WiFi Sense: HotSpot Sharing: Disable
If (-Not (Test-Path "HKLM:\Software\Microsoft\PolicyManager\default\WiFi\AllowWiFiHotSpotReporting")) {
    New-Item -Path HKLM:\Software\Microsoft\PolicyManager\default\WiFi\AllowWiFiHotSpotReporting | Out-Null
}
Set-ItemProperty -Path HKLM:\Software\Microsoft\PolicyManager\default\WiFi\AllowWiFiHotSpotReporting -Name value -Type DWord -Value 0

# WiFi Sense: Shared HotSpot Auto-Connect: Disable
Set-ItemProperty -Path HKLM:\Software\Microsoft\PolicyManager\default\WiFi\AllowAutoConnectToWiFiSenseHotspots -Name value -Type DWord -Value 0

# Start Menu: Disable Bing Search Results
Set-ItemProperty -Path HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Search -Name BingSearchEnabled -Type DWord -Value 0
# To Restore (Enabled):
# Set-ItemProperty -Path HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Search -Name BingSearchEnabled -Type DWord -Value 1

# Disable Telemetry (requires a reboot to take effect)
# Note this may break Insider builds for your organization
Set-ItemProperty -Path HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection -Name AllowTelemetry -Type DWord -Value 0
# Get-Service DiagTrack,Dmwappushservice | Stop-Service | Set-Service -StartupType Disabled

# Change Explorer home screen back to "This PC"
Set-ItemProperty -Path HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced -Name LaunchTo -Type DWord -Value 1
# Change it back to "Quick Access" (Windows 10 default)
# Set-ItemProperty -Path HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced -Name LaunchTo -Type DWord -Value 2

# Better File Explorer
#Set-ItemProperty -Path HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced -Name NavPaneExpandToCurrentFolder -Value 1		
#Set-ItemProperty -Path HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced -Name NavPaneShowAllFolders -Value 1		
#Set-ItemProperty -Path HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced -Name MMTaskbarMode -Value 2

# These make "Quick Access" behave much closer to the old "Favorites"
# Disable Quick Access: Recent Files
Set-ItemProperty -Path HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer -Name ShowRecent -Type DWord -Value 0
# Disable Quick Access: Frequent Folders
Set-ItemProperty -Path HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer -Name ShowFrequent -Type DWord -Value 0
# To Restore:
# Set-ItemProperty -Path HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer -Name ShowRecent -Type DWord -Value 1
# Set-ItemProperty -Path HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer -Name ShowFrequent -Type DWord -Value 1

# Disable the Lock Screen (the one before password prompt - to prevent dropping the first character)
#If (-Not (Test-Path HKLM:\SOFTWARE\Policies\Microsoft\Windows\Personalization)) {
#	New-Item -Path HKLM:\SOFTWARE\Policies\Microsoft\Windows -Name Personalization | Out-Null
#}
#Set-ItemProperty -Path HKLM:\SOFTWARE\Policies\Microsoft\Windows\Personalization -Name NoLockScreen -Type DWord -Value 1
# To Restore:
# Set-ItemProperty -Path HKLM:\SOFTWARE\Policies\Microsoft\Windows\Personalization -Name NoLockScreen -Type DWord -Value 1

# Lock screen (not sleep) on lid close
Set-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Power' -Name AwayModeEnabled -Type DWord -Value 1
# To Restore:
# Set-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Power' -Name AwayModeEnabled -Type DWord -Value 0

# Use the Windows 7-8.1 Style Volume Mixer
#If (-Not (Test-Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\MTCUVC")) {
#	New-Item -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion" -Name MTCUVC | Out-Null
#}
#Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\MTCUVC" -Name EnableMtcUvc -Type DWord -Value 0
# To Restore (Windows 10 Style Volume Control):
# Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\MTCUVC" -Name EnableMtcUvc -Type DWord -Value 1

# Disable Xbox Gamebar
Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\GameDVR" -Name AppCaptureEnabled -Type DWord -Value 0
Set-ItemProperty -Path "HKCU:\System\GameConfigStore" -Name GameDVR_Enabled -Type DWord -Value 0

# Turn off People in Taskbar
If (-Not (Test-Path "HKCU:SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced\People")) {
    New-Item -Path HKCU:SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced\People | Out-Null
}
Set-ItemProperty -Path "HKCU:SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced\People" -Name PeopleBand -Type DWord -Value 0

# Install updates
Invoke-Boxstarter -ScriptToCall -Password $Password {
    Install-WindowsUpdate -All -AcceptEula
    if (Test-PendingReboot) { Invoke-Reboot }
}
