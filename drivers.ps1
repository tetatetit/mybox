Install-BoxstarterPackage -PackageName "vmware-tools"
if (Test-PendingReboot) { Invoke-Reboot }
