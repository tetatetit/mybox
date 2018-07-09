choco update -y "vmware-tools"
if (Test-PendingReboot) { Invoke-Reboot }
