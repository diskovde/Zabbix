param(
	[string]$VMHost,
	[string]$Device = ""
	)
Import-Module (Join-Path $env:ZABBIX_CONFDIR "SuperZabbix") -Force

Get-SMARTParameters -VMHost $VMHost -Device $Device