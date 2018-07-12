$Boxstarter.RebootOk = $true # Allow reboots?
$Boxstarter.AutoLogin = $true # Save my password securely and auto-login after a reboot
$Password = Read-Host -AsSecureString "Autologon Password"
$Boxstarter.NoPassword = $Password.Length -eq 0

# Set Windows Update to:
# * Semi-Annual Channel
# * Defer features update to max possible 365 (until they a well tested)
# * Notify for download and auto install
$WindowsUpdatePath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate"
New-Item -Path $WindowsUpdatePath -Force
Set-ItemProperty -Path $WindowsUpdatePath -Name BranchReadinessLevel -Type DWord -Value 32 -Force
Set-ItemProperty -Path $WindowsUpdatePath -Name DeferFeatureUpdates -Type DWord -Value 1 -Force
Set-ItemProperty -Path $WindowsUpdatePath -Name DeferFeatureUpdatesPeriodInDays -Type DWord -Value 365 -Force
New-Item -Path "$WindowsUpdatePath\AU" -Force
Set-ItemProperty -Path "$WindowsUpdatePath\AU" -Name AUOptions -Type DWord -Value 2 -Force

Invoke-Boxstarter -RebootOk -Password $Password -NoPassword $Boxstarter.NoPassword -ScriptToCall {
    Install-WindowsUpdate -AcceptEula
}
