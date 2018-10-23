#$Boxstarter.RebootOk = $true # Allow reboots?
#$Boxstarter.AutoLogin = $true # Save my password securely and auto-login after a reboot
#$Boxstarter.NoPassword = true

if(-not (Test-Path "c:\mybox-configured")) {

#Update-ExecutionPolicy Unrestricted
#Set-ExecutionPolicy -Force RemoteSigned

Disable-ComputerRestore -Drive "C:\"

# Never sleep
powercfg -change standby-timeout-ac 0
powercfg -change standby-timeout-dc 0
powercfg -change hibernate-timeout-ac 0
powercfg -change hibernate-timeout-dc 0

# Set Windows Update to:
# * No auto update (if you want "Notify before download and install" - incomment commented and set NoAutoUpdate to 0)
# * Semi-Annual Channel
# * Defer features update to max possible 365 (until they a well tested)
$WindowsUpdatePath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate"
New-Item -Path $WindowsUpdatePath -Force
Set-ItemProperty -Path $WindowsUpdatePath -Name BranchReadinessLevel -Type DWord -Value 32 -Force
Set-ItemProperty -Path $WindowsUpdatePath -Name DeferFeatureUpdates -Type DWord -Value 1 -Force
Set-ItemProperty -Path $WindowsUpdatePath -Name DeferFeatureUpdatesPeriodInDays -Type DWord -Value 365 -Force
Set-ItemProperty -Path $WindowsUpdatePath -Name DeferQualityUpdates -Type DWord -Value 1 -Force
Set-ItemProperty -Path $WindowsUpdatePath -Name DeferQualityUpdatesPeriodInDays -Type DWord -Value 0 -Force
Set-ItemProperty -Path $WindowsUpdatePath -Name ManagePreviewBuilds -Type DWord -Value 1 -Force
Set-ItemProperty -Path $WindowsUpdatePath -Name ManagePreviewBuildsPolicyValue -Type DWord -Value 0 -Force
Set-ItemProperty -Path $WindowsUpdatePath -Name PauseFeatureUpdatesStartTime -Value ""
Set-ItemProperty -Path $WindowsUpdatePath -Name PauseQualityUpdatesStartTime -Value ""
New-Item -Path "$WindowsUpdatePath\AU" -Force
#Set-ItemProperty -Path "$WindowsUpdatePath\AU" -Name AUOptions -Type DWord -Value 2 -Force
Set-ItemProperty -Path "$WindowsUpdatePath\AU" -Name NoAutoUpdate -Type DWord -Value 1 -Force
Set-ItemProperty -Path "$WindowsUpdatePath\AU" -Name AllowMUUpdateService -Type DWord -Value 1 -Force
Set-ItemProperty -Path "$WindowsUpdatePath\AU" -Name IncludeRecommendedUpdates -Type DWord -Value 1 -Force
Set-ItemProperty -Path "$WindowsUpdatePath\AU" -Name NoAutoRebootWithLoggedOnUsers -Type DWord -Value 1 -Force
#Set-ItemProperty -Path "$WindowsUpdatePath\AU" -Name ScheduledInstallDay -Type DWord -Value 0 -Force
#Set-ItemProperty -Path "$WindowsUpdatePath\AU" -Name ScheduledInstallEveryWeek -Type DWord -Value 1 -Force
#Set-ItemProperty -Path "$WindowsUpdatePath\AU" -Name ScheduledInstallTime -Type DWord -Value 3 -Force
Set-Service -Name wuauserv -StartupType Disabled

# Disable windows defender
if (Get-Command "Set-MpPreference" -errorAction SilentlyContinue) {
    Set-MpPreference -DisableRealtimeMonitoring $true
}
$DefenderPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender"
New-Item -Path $DefenderPath -Force
Set-ItemProperty -Path $DefenderPath -Name DisableAntiSpyware -Type DWord -Value 1 -Force
Set-ItemProperty -Path $DefenderPath -Name ServiceKeepAlive -Type DWord -Value 0 -Force
New-Item -Path "$DefenderPath\Real-Time Protection" -Force
Set-ItemProperty -Path "$DefenderPath\Real-Time Protection" -Name DisableRealtimeMonitoring -Type DWord -Value 1 -Force
Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\StartupApproved\Run" -Name "SecurityHealth" -Value ([byte[]]("07,00,00,00,d6,0e,8d,7b,ea,f5,d3,01".Split(',') | % { "0x$_"}))

# Disable Remote Assistance
Set-ItemProperty -Path  "HKLM:\SYSTEM\CurrentControlSet\Control\Remote Assistance" -Name "fAllowToGetHelp" -Type DWord -Value 0 -Force 

# Disable Cortana
#$WindowsSearchPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search"
#New-Item -Path $WindowsSearchPath -Force
#Set-ItemProperty -Path  "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search" -Name "AllowCortana" -Type DWord -Value 0 -Force 

# Disable Automatic Maintenance
Set-ItemProperty -Path  "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Schedule\Maintenance" -Name "MaintenanceDisabled" -Type DWord -Value 1 -Force

# Disable automatic diagnostics
Set-ItemProperty -Path  "HKLM:\SOFTWARE\Policies\Microsoft\Windows\ScheduledDiagnostics" -Name "EnabledExecution" -Type DWord -Value 1 -Force

# Disable Background Apps
Set-ItemProperty -Path  "HKCU:\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications" -Name "GlobalUserDisabled" -Type DWord -Value 1 -Force 
#Set-ItemProperty -Path  "HKLM:Software\Policies\Microsoft\Windows\AppPrivacy" -Name "LetAppsRunInBackground" -Type DWord -Value 2 -Force 

# Disable Smart Screen
Set-ItemProperty -Path  "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System" -Name "EnableSmartScreen" -Type DWord -Value 0 -Force 

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
Set-ItemProperty -Path HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection -Name AllowTelemetry -Type DWord -Value 1
Get-Service DiagTrack,Dmwappushservice | Stop-Service | Set-Service -StartupType Disabled

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

# Disable Xbox Gamebar (if not uninstalled)
#Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\GameDVR" -Name AppCaptureEnabled -Type DWord -Value 0
#Set-ItemProperty -Path "HKCU:\System\GameConfigStore" -Name GameDVR_Enabled -Type DWord -Value 0

# Turn off People in Taskbar
If (-Not (Test-Path "HKCU:SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced\People")) {
    New-Item -Path HKCU:SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced\People | Out-Null
}

Set-ItemProperty -Path "HKCU:SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced\People" -Name PeopleBand -Type DWord -Value 0

Disable-BingSearch
Disable-GameBarTips
Set-WindowsExplorerOptions -EnableShowFileExtensions
Set-TaskbarOptions -AlwaysShowIconsOn
Enable-RemoteDesktop -DoNotRequireUserLevelAuthentication

fc > "c:\mybox-configured"
}

# --- Uninstall crapware ---

# Uninstall McAfee Security App
$mcafee = gci "HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall" | foreach { gp $_.PSPath } | ? { $_ -match "McAfee Security" } | select UninstallString
if ($mcafee) {
	$mcafee = $mcafee.UninstallString -Replace "C:\Program Files\McAfee\MSC\mcuihost.exe",""
	Write "Uninstalling McAfee..."
	start-process "C:\Program Files\McAfee\MSC\mcuihost.exe" -arg "$mcafee" -Wait
}

# Uinstall OneDrive (to install older v17 one)
taskkill /f /im OneDrive.exe
if (Test-Path "$env:systemroot\SysWOW64\OneDriveSetup.exe") {
    & "$env:systemroot\SysWOW64\OneDriveSetup.exe" /uninstall
} elseif (Test-Path "$env:systemroot\System32\OneDriveSetup.exe") {
    & "$env:systemroot\System32\OneDriveSetup.exe" /uninstall
}

if (Get-Command "Get-AppxPackage" -errorAction SilentlyContinue) {

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
    "*Microsoft.MSPaint*"
)
foreach($app in $AppsToRemove) {
	Get-AppxPackage $app | Where-Object {$_.Name -notlike "Microsoft.XboxGameCallableUI*" } | Remove-AppxPackage
	Get-AppxProvisionedPackage -Online | Where-Object {$_.PackageName -like $app} | Remove-AppxProvisionedPackage -Online
}

}

Set-Service -Name wuauserv -StartupType Manual
Start-Service -Name wuauserv
Install-WindowsUpdate -AcceptEula
Set-Service -Name wuauserv -StartupType Disabled

if(Test-PendingReboot) {
    Invoke-Reboot
}

#choco upgrade -y vmware-tools

#if(Test-PendingReboot) {
#    Invoke-Reboot
#}
