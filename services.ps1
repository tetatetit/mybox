$servicesPath = "HKLM:\System\CurrentControlSet\Services"

function set-startType($serviceName, $startType) {
  $servicePath = "$servicesPath\$serviceName"
  if(-not (get-itemProperty -Path $servicePath -Name StartDefault -ErrorAction SilentlyContinue)) {
    $defaultStartType = (get-itemProperty -Path $servicePath -Name Start).Start
    set-ItemProperty -Force -Path $servicePath -Name StartDefault -Type DWord -Value $defaultStartType
  }
  set-ItemProperty -Path $servicePath -Name Start -Type DWord -Value $startType -Force
}

function restore-startType($serviceName) {
  $servicePath = "$servicesPath\$serviceName"
  $defaultStartType = (get-itemProperty -Path $servicePath -Name StartDefault -ErrorAction SilentlyContinue).StartDefault
  if($defaultStartType) {
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

ds  AppXSvc
ms  AudioEndpointBuilder
ms  Audiosrv
ms  CDPSvc
ms  CDPUserSvc
ms  DiagTrack
ms  DPS
ms  DusmSvc
ms  EventSystem
ds  FontCache
ms  gpsvc
ds  HomeGroupProvider
ms  iphlpsvc
ds  LanmanServer
ds  LanmanWorkstation
ds  lmhosts
ms  MpsSvc
ds  NcbService
ds  NcdAutoSetup
ds  netprofm
ms  OneSyncSvc
ds  PolicyAgent
ds  Power
ms  RasMan
ms  SamSs
ds  ScDeviceEnum
ds  Schedule
ms  SecurityHealthService
ms  SENS
ds  SensorService
ds  ShellHWDetection
ms  Spooler
ds  SSDPSRV
ms  SysMain
ms  Themes
ds  TimeBrokerSvc
ds  TokenBroker
ms  TrkWks
ds  UmRdpService
ms  VGAuthService
ms  VMTools
ms  "VMware Physical Disk Helper Service"
ds  WdiServiceHost
ds  WinHttpAutoProxySvc
ms  WpnService
ms  WpnUserService
ms  wscsvc
ds  WSearch
ds  wuauserv
