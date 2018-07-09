# Update Windows and reboot if necessary
Install-WindowsUpdate -All -AcceptEula
if (Test-PendingReboot) { Invoke-Reboot }
