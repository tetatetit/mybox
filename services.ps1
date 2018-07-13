$servicesPath = "HKLM:\System\CurrentControlSet\Services"
$startTypes = @{
  Automatic = 2
  Manual = 3
  Disabled = 4
}

function Set-ServiceStartType($serviceName, $startType) {
  $service = get-service -name $serviceName | select StartType,Name,DisplayName
  if($service) {
    export-cvs -inputObject $service -append C:\mybox-services.csv
    Set-ItemProperty -Path "$servicesPath\$($svc.Name)" -Name Start -Type DWord -Value $startTypes[$startType] -Force
  }
}
