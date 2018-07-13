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

ms	AudioEndpointBuilder
ms	Audiosrv
ms	CDPSvc
ms	CDPUserSvc_25d4f
ms  CryptSvc
ms	DiagTrack
ms	DPS
ms	DusmSvc
ms	EventSystem
ms	FontCache
ms	gpsvc
ms	iphlpsvc
ms	LanmanServer
ms  LanmanWorkstation
ms  MpsSvc
ms	OneSyncSvc_25d4f
ms  Power
ms	RasMan
ms	SamSs
ms	Schedule
ms	SecurityHealthService
ms	SENS
ms	ShellHWDetection
ms	Spooler
ms	SysMain
ms  TabletInputService
ms	Themes
ms	TrkWks
ms	VGAuthService
ms	VMTools
ms	VMware Physical Disk Helper Service
ms	WpnService
ms	WpnUserService_25d4f
ms	wscsvc
ms	WSearch
