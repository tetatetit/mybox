$servicesPath = "HKLM:\System\CurrentControlSet\Services"

function set-startType($serviceName, $startType) {
  $servicePath = $servicesPath\$serviceName
  if(-not ($defaultStartType = get-itemProperty -Path $servicePath -Name StartDefault)) {
    Set-ItemProperty -Path $servicePath -Name StartDefault -Type DWord -Value $defaultStartType -Force
  }
  Set-ItemProperty -Path $servicePath -Name Start -Type DWord -Value $startType -Force
}

function restore-startType($serviceName) {
  $servicePath = $servicesPath\$serviceName
  if($defaultStartType = get-itemProperty -Path $servicePath -Name StartDefault) {
    set-ItemProperty -Path $servicePath -Name Start -Type DWord -Value $defaultStartType -Force
    remove-ItemProperty -Path $servicePath -Name StartDefault
  }
}

function d($serviceName) {
  set-startType $serviceName 4
}

function m($serviceName) {
  set-startType $serviceName 3
}

function r($serviceName) {
  restore-startType $serviceName
}


d wscsvc
