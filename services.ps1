$servicesPath = "HKLM:\System\CurrentControlSet\Services"

function set-startType($serviceName, $startType) {
  $servicePath = "$servicesPath\$serviceName"
  if(-not get-itemProperty -Path $servicePath -Name StartDefault -ErrorAction SilentlyContinue) {
    set-ItemProperty -Force -Path $servicePath -Name StartDefault -Type DWord \
      -Value get-itemProperty -Path $servicePath -Name Start
  }
  set-ItemProperty -Path $servicePath -Name Start -Type DWord -Value $startType -Force
}

function restore-startType($serviceName) {
  $servicePath = "$servicesPath\$serviceName"
  if($defaultStartType = get-itemProperty -Path $servicePath -Name StartDefault -ErrorAction SilentlyContinue) {
    set-ItemProperty -Path $servicePath -Name Start -Type DWord -Value $defaultStartType -Force
    remove-ItemProperty -Path $servicePath -Name StartDefault
  }
}

function ds($serviceName) {
  set-startType $serviceName 4
}

function ms($serviceName) {
  set-startType $serviceName 3
}

function rs($serviceName) {
  restore-startType $serviceName
}


ds wscsvc
