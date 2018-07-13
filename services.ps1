$servicesPath = "HKLM:\System\CurrentControlSet\Services"

function Set-AutoToManual () {
  $autoServices = get-service | Where-Object {$_.StartType -like "Automatic"}
  $autoServices | Export-Csv -Path C:\auto-services.csv
  foreach ($svc in $autoServices) {
    Set-ItemProperty -Path $servicesPath\$svc.Name -Name Start -Type DWord -Value 3 -Force
  }
}

function Set-ManualToAuto () {
  $autoServices = Import-Csv -Path C:\auto-services.csv
  foreach ($svc in $autoServices) {
    Set-ItemProperty -Path $servicesPath\$svc.Name -Name Start -Type DWord -Value 2 -Force
  }
}
