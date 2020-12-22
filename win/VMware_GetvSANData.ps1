param(
	[string]$VMHost,
	[string]$DGId = ""
	)
Import-Module (Join-Path $env:ZABBIX_CONFDIR "SuperZabbix") -Force

Get-vSANParameters -VMHost $VMHost -DGId $DGId