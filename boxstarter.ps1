# Install boxstarter:
# 	. { iwr -useb http://boxstarter.org/bootstrapper.ps1 } | iex; get-boxstarter -Force
#
# You might need to set: Set-ExecutionPolicy RemoteSigned
#
# Run this boxstarter by calling the following from an **elevated** command-prompt:
# 	start http://boxstarter.org/package/nr/url?https://raw.githubusercontent.com/tetatetit/mybox/master/initial.ps1
# OR
# 	Install-BoxstarterPackage -PackageName https://raw.githubusercontent.com/tetatetit/mybox/master/initial.ps1
#
# Learn more: http://boxstarter.org/Learn/WebLauncher

#Disable-UAC
$Boxstarter.RebootOk = $true # Allow reboots?
$Boxstarter.NoPassword = $false # Is this a machine with no login password?
$Boxstarter.AutoLogin = $true # Save my password securely and auto-login after a reboot

Update-ExecutionPolicy Unrestricted
#Set-ExecutionPolicy -Force RemoteSigned
Disable-ComputerRestore -Drive "C:\"
Enable-RemoteDesktop -DoNotRequireUserLevelAuthentication
Disable-BingSearch
Disable-GameBarTips
Set-WindowsExplorerOptions -EnableShowFileExtensions
Set-TaskbarOptions -AlwaysShowIconsOn

Invoke-Boxstarter -ScriptToCall -RebootOk {
    Install-WindowsUpdate -All -AcceptEula
}


